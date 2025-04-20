#include "Network.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int wmain()
{
	DanbiNetworkSelect::eInitMode initMode;

	initMode = DanbiNetworkSelect::Initialize(L"0.0.0.0", 9000, 1, 65535, 1, true);
	if (initMode != DanbiNetworkSelect::eInitMode::INIT_SUCCESS)
	{
		return 1;
	}

	return 0;
}