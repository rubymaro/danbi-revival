#include "DanbiNetworkSelect.h"
#include "Types.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int RunServer(DanbiNetworkSelect::Instance* const pInstance);
bool OnClientJoined(const SESSION_ID sessionId);
void OnClientLeaved(const SESSION_ID sessionId);
void OnMessageRecieved(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData);

int wmain()
{
	DanbiNetworkSelect::Instance* pInstanceOrNull;

	pInstanceOrNull = DanbiNetworkSelect::CreateOrNull(L"0.0.0.0", 9000, 1, 65535, 1, true, 2048, 1024, OnClientJoined, OnClientLeaved, OnMessageRecieved);
	if (pInstanceOrNull == nullptr)
	{
		return 1;
	}

	RunServer(pInstanceOrNull);

	DanbiNetworkSelect::Finalize(pInstanceOrNull);

	delete pInstanceOrNull;

	return 0;
}

int RunServer(DanbiNetworkSelect::Instance* const pInstance)
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