#include <malloc.h>

#include "DanbiServer.h"

int wmain()
{
	DanbiNetworkSelect::Instance* pInstanceOrNull;

	pInstanceOrNull = DanbiNetworkSelect::CreateOrNull(L"0.0.0.0", 9000, 1, 65535, 1, true, 2048, 1024, DanbiServer::OnClientJoined, DanbiServer::OnClientLeaved, DanbiServer::OnMessageRecieved);
	if (pInstanceOrNull != nullptr)
	{
		DanbiServer::Run(pInstanceOrNull);

		DanbiNetworkSelect::Finalize(pInstanceOrNull);

		free(pInstanceOrNull);
	}

	return 0;
}