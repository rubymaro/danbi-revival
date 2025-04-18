#include "Network.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int wmain()
{
	InitializeNetwork(L"0.0.0.0", 9000, 65535, 1, true);

	return 0;
}