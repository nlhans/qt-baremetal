#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char** argv)
{
	assert(argc == 3);
	char cmd[1024];
	snprintf(cmd, 1024, "arm-none-eabi-objdump %s -D -S > %s", argv[1], argv[2]);
	system(cmd);
	return EXIT_SUCCESS;
}
