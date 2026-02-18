/* imports */
#include <stdio.h>
#include <sys/param.h>

#include "nvs_flash.h"

#include "esp_wifi.h"
#include "esp_log.h"
#include "esp_http_server.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

/* macros */
#define MAX_SSID_LEN 32
#define MAX_PASS_LEN 64

#define WIFI_SUCCESS 1 << 0
#define WIFI_FAILURE 1 << 1

/* function declarations */
bool wifi_load_credentials(char *, char *);
esp_err_t wifi_save_credentials(const char *, const char *);
esp_err_t wifi_erase_credentials(void);
void wifi_init_sta(const char *, const char *);
void wifi_init_softap(void);
void wifi_init_websrv(void);
void wifi_event_handler(void *, esp_event_base_t, int32_t, void *);
esp_err_t wifi_get_handler(httpd_req_t *);
esp_err_t wifi_post_handler(httpd_req_t *);

/* global variables */
const char *TAG_WIFI = "wifi_manager";

EventGroupHandle_t weg;

int retry_num = 0;

/* function definitions */
bool
wifi_load_credentials(char *ssid, char *pass)
{
	nvs_handle_t nvs;
	size_t ssid_len = MAX_SSID_LEN;
	size_t pass_len = MAX_PASS_LEN;

	if (nvs_open("storage", NVS_READONLY, &nvs) != ESP_OK)
		return false;

	if (nvs_get_str(nvs, "ssid", ssid, &ssid_len) != ESP_OK) {
		nvs_close(nvs);
		return false;
	}

	if (nvs_get_str(nvs, "pass", pass, &pass_len) != ESP_OK) {
		nvs_close(nvs);
		return false;
	}

	nvs_close(nvs);
	return true;
}

esp_err_t
wifi_save_credentials(const char *ssid, const char *pass)
{
	nvs_handle_t nvs;
	ESP_ERROR_CHECK(nvs_open("storage", NVS_READWRITE, &nvs));
	ESP_ERROR_CHECK(nvs_set_str(nvs, "ssid", ssid));
	ESP_ERROR_CHECK(nvs_set_str(nvs, "pass", pass));
	ESP_ERROR_CHECK(nvs_commit(nvs));
	nvs_close(nvs);
	ESP_LOGI(TAG_WIFI, "Wifi credentials saved");
	return ESP_OK;
}

esp_err_t
wifi_erase_credentials(void)
{
	nvs_handle_t nvs;
	ESP_ERROR_CHECK(nvs_open("storage", NVS_READWRITE, &nvs));
	ESP_ERROR_CHECK(nvs_erase_key(nvs, "ssid"));
	ESP_ERROR_CHECK(nvs_erase_key(nvs, "pass"));
	ESP_ERROR_CHECK(nvs_commit(nvs));
	nvs_close(nvs);
	ESP_LOGI(TAG_WIFI, "Wifi credentials erased");
	return ESP_OK;
}

void
wifi_init_sta(const char *ssid, const char *pass)
{
	weg = xEventGroupCreate();

	esp_netif_create_default_wifi_sta();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	esp_event_handler_instance_t wfe_inst;
	ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID,
		&wifi_event_handler, NULL, &wfe_inst));

	esp_event_handler_instance_t ipe_inst;
	ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT, IP_EVENT_STA_GOT_IP,
		&wifi_event_handler, NULL, &ipe_inst));

	wifi_config_t wcfg = {0};
	strcpy((char *)wcfg.sta.ssid, ssid);
	strcpy((char *)wcfg.sta.password, pass);

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
	ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wcfg));
	ESP_ERROR_CHECK(esp_wifi_start());

	EventBits_t bits = xEventGroupWaitBits(weg, WIFI_SUCCESS | WIFI_FAILURE,
		pdFALSE, pdFALSE, portMAX_DELAY);

	if (bits & WIFI_FAILURE) {
		wifi_erase_credentials();
		esp_restart();
	}

	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT,
		IP_EVENT_STA_GOT_IP, ipe_inst));
	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT,
		ESP_EVENT_ANY_ID, wfe_inst));

	vEventGroupDelete(weg);
}

void
wifi_init_softap(void)
{
	esp_netif_create_default_wifi_ap();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	wifi_config_t wcfg = {
		.ap = {
			.ssid = "Smart Parcel Box",
			.ssid_len = strlen("Smart Parcel Box"),
			.password = "12345678",
			.max_connection = 2,
			.authmode = WIFI_AUTH_WPA_WPA2_PSK,
		},
	};

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));
	ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &wcfg));
	ESP_ERROR_CHECK(esp_wifi_start());

	ESP_LOGI(TAG_WIFI, "SoftAP started");
}

void
wifi_init_websrv(void)
{
	httpd_config_t cfg = HTTPD_DEFAULT_CONFIG();
	httpd_handle_t srv = NULL;

	if (httpd_start(&srv, &cfg) == ESP_OK) {
		httpd_uri_t root_get = {
			.uri = "/",
			.method = HTTP_GET,
			.handler = wifi_get_handler,
		};
		httpd_register_uri_handler(srv, &root_get);

		httpd_uri_t root_post = {
			.uri = "/",
			.method = HTTP_POST,
			.handler = wifi_post_handler,
		};
		httpd_register_uri_handler(srv, &root_post);
	}
}

void
wifi_event_handler(void *arg, esp_event_base_t eb, int32_t eid, void *ed)
{
	if (eb == WIFI_EVENT && eid == WIFI_EVENT_STA_START)
		esp_wifi_connect();
	else if (eb == WIFI_EVENT && eid == WIFI_EVENT_STA_DISCONNECTED)
	{
		if (retry_num < 10) {
			ESP_LOGI(TAG_WIFI, "Retry connection...");
			esp_wifi_connect();
			retry_num++;
		} else {
			xEventGroupSetBits(weg, WIFI_FAILURE);
		}
	} else if (eb == IP_EVENT && eid == IP_EVENT_STA_GOT_IP)
	{
		ESP_LOGI(TAG_WIFI, "Connected to WiFi");
		xEventGroupSetBits(weg, WIFI_SUCCESS);
	}
}

esp_err_t
wifi_get_handler(httpd_req_t *req)
{
	const char *resp =
		"<form action=\"/\" method=\"post\">"
		"SSID:<input name=\"ssid\"><br>"
		"Password:<input name=\"pass\"><br>"
		"<input type=\"submit\" value=\"Save\">"
		"</form>";
	httpd_resp_send(req, resp, HTTPD_RESP_USE_STRLEN);
	return ESP_OK;
}

esp_err_t
wifi_post_handler(httpd_req_t *req)
{
	char buf[200];
	int ret = httpd_req_recv(req, buf, MIN(req->content_len, sizeof(buf)));
	if (ret <= 0)
		return ESP_FAIL;

	buf[ret] = '\0';

	char ssid[32] = {0};
	char pass[64] = {0};

	sscanf(buf, "ssid=%31[^&]&pass=%63s", ssid, pass);

	wifi_save_credentials(ssid, pass);

	httpd_resp_sendstr(req, "Saved! Restarting...");
	vTaskDelay(2000 / portTICK_PERIOD_MS);
	esp_restart();
	return ESP_OK;
}

/* main */
void
app_main(void)
{
	/* initialize */
	esp_err_t ret = nvs_flash_init();
	if (ret == ESP_ERR_NVS_NO_FREE_PAGES
		|| ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
		ESP_ERROR_CHECK(nvs_flash_erase());
		ret = nvs_flash_init();
	}
	ESP_ERROR_CHECK(ret);

	ESP_ERROR_CHECK(esp_netif_init());
	ESP_ERROR_CHECK(esp_event_loop_create_default());
	
	char ssid[MAX_SSID_LEN] = {0};
	char pass[MAX_PASS_LEN] = {0};

	if (wifi_load_credentials(ssid, pass)) {
		ESP_LOGI(TAG_WIFI, "Found saved WiFi. Connecting...");
		wifi_init_sta(ssid, pass);
	} else {
		ESP_LOGI(TAG_WIFI, "No WiFi saved. Starting AP...");
		wifi_init_softap();
		wifi_init_websrv();
	}
}
