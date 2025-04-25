#pragma once

#include "DanbiNetworkSelect.h"
#include "Types.h"

#pragma comment(lib, "./DanbiNetworkSelect.lib")

namespace DanbiServer
{
	int Run(DanbiNetworkSelect::Instance* const pInstance);
	bool OnClientJoined(const SESSION_ID sessionId);
	void OnClientLeaved(const SESSION_ID sessionId);
	void OnMessageRecieved(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData);
}