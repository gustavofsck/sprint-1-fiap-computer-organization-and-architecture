#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

#define LIMIT_BATTERY 	  100
#define LIMIT_TEMPERATURE 45
#define LIMIT_CURRENT     32

#define VALID_ID '1'

void handle_tempe_error()
{
	printf("ERRO: a temperatura excedeu o limite permitdo\n");
	exit(0);
}

void handle_current_error()
{
	printf("ERRO: a corrente excedeu o limite permitdo\n");
	exit(0);
}

void setup_sensors(int* sensor_battery, int* sensor_temperature, int* sensor_current)
{
	*sensor_battery = 55;
	*sensor_temperature = 35;
	*sensor_current = 16;	
}

int main()
{

	const char* msg = "Por favor digite seu ID: \n";
	const char* valid_id_msg = "ID correto, a carregar o veiculo...\n";
	const char* wrong_id_msg = "ID errado, por favor tente novamente!\n";
	const char* auth_fail_msg = "Falha ao autenticar o usuario! Tente novamente mais tarde.\n";

	const char* charged_msg_1 = "% de bateria -> ";
	const char* charged_msg_2 = "% de bateria ";
	const char* charging_msg = "Carregando... ";

	constexpr char carriage_ret = '\r';

	int max_tries = 5;
	
	char ustr;

	for(int i = 0; i < max_tries; i++)
	{
		
		printf("%s", msg);
		scanf(" %c", &ustr);

		while (getchar() != '\n');

		if(ustr == VALID_ID)
		{
			break;
		}

		printf("%s", wrong_id_msg);
		max_tries--;
	}

	if(ustr != VALID_ID)
	{
		printf("%s" , auth_fail_msg);
		return 0;
	}

	int sensor_battery = 0;
	int sensor_temperature = 0;
	int sensor_current = 0;

	setup_sensors(&sensor_battery, &sensor_temperature, &sensor_current);

	int previous_battery = sensor_battery;

	printf("%s", valid_id_msg);

	for(int i = sensor_battery; i < LIMIT_BATTERY; i++)
	{

		if(sensor_temperature >= LIMIT_TEMPERATURE)
		{
			handle_tempe_error();
		}

		if(sensor_current >= LIMIT_CURRENT)
		{
			handle_current_error();
		}

		printf("%s%d%s", charging_msg, sensor_battery, charged_msg_2);
		printf("%c", carriage_ret);
		fflush(stdout);
	
		sensor_battery++;

		sleep(1);
	}

	printf("%d%s%d%s", previous_battery, charged_msg_1, sensor_battery, charged_msg_2);

	return 0;
}
