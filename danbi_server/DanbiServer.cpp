#include <cstdio>
#include <Windows.h>

#include "DanbiServer.h"
#include "SerializedBuffer.h"

int DanbiServer::Run(DanbiNetworkSelect::Instance* const pInstance)
{
	for (;;)
	{
		DanbiNetworkSelect::Update(pInstance);
	}

	return 0;
}

bool DanbiServer::OnClientJoined(const SESSION_ID sessionId)
{
	wprintf(L"[%s:%5u] sessionId = %llu\n", TEXT(__FUNCTION__), GetCurrentThreadId(), sessionId);

	return true;
}

void DanbiServer::OnClientLeaved(const SESSION_ID sessionId)
{
	wprintf(L"[%s:%5u] sessionId = %llu\n", TEXT(__FUNCTION__), GetCurrentThreadId(), sessionId);
}

bool DanbiServer::OnMessageReceived(const SESSION_ID sessionId, const MESSAGE_TYPE type, SerializedBuffer& msg)
{
	wprintf(L"[%s:%5u] sessionId = %llu\ttype = %hu\tmsg.size=%zu\n", TEXT(__FUNCTION__), GetCurrentThreadId(), sessionId, type, msg.Size());

	return true;
}