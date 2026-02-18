/* imports */
#include <stdio.h>

#include "esp_log.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "driver/gpio.h"

/* main */
void
app_main(void)
{
	char *task = pcTaskGetName(0);
	ESP_LOGI(task, "Hi mom!\n");

	gpio_reset_pin(2);
	gpio_set_direction(2, GPIO_MODE_OUTPUT);

	while(1)
	{
		gpio_set_level(2, 1);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
		gpio_set_level(2, 0);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}
