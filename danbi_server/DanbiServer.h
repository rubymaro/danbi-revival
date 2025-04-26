#pragma once

#include "DanbiNetworkSelect.h"
#include "Types.h"

#pragma comment(lib, "./DanbiNetworkSelect.lib")

namespace DanbiServer
{
	int Run(DanbiNetworkSelect::Instance* const pInstance);
	bool OnClientJoined(const SESSION_ID sessionId);
	void OnClientLeaved(const SESSION_ID sessionId);
	bool OnMessageReceived(const SESSION_ID sessionId, const MESSAGE_TYPE type, SerializedBuffer& msg);
}