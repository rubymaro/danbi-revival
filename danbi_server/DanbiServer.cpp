#include "DanbiNetworkSelect.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int RunServer(void);

int wmain()
{
	DanbiNetworkSelect::eInitMode initMode;

	initMode = DanbiNetworkSelect::Initialize(L"0.0.0.0", 9000, 1, 65535, 1, true);
	if (initMode != DanbiNetworkSelect::eInitMode::INIT_SUCCESS)
	{
		return 1;
	}

	RunServer();

	DanbiNetworkSelect::Finalize();

	return 0;
}

int RunServer(void)
{
	return 0;
}