#include "DanbiServer.h"

namespace DanbiServer
{
	int Run(DanbiNetworkSelect::Instance* const pInstance)
	{
		for (;;)
		{
			DanbiNetworkSelect::Update(pInstance);
		}

		return 0;
	}

	bool OnClientJoined(const SESSION_ID sessionId)
	{
		return true;
	}

	void OnClientLeaved(const SESSION_ID sessionId)
	{

	}

	void OnMessageRecieved(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData)
	{

	}
}