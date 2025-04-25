#include "DanbiNetworkSelect.h"
#include "Types.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int RunServer(DanbiNetworkSelect::Model* const pModel);
bool OnClientJoined(const SESSION_ID sessionId);
void OnClientLeaved(const SESSION_ID sessionId);
void OnMessageRecieved(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData);

int wmain()
{
	DanbiNetworkSelect::Model* pModelOrNull;

	pModelOrNull = DanbiNetworkSelect::CreateOrNull(L"0.0.0.0", 9000, 1, 65535, 1, true, 2048, 1024, OnClientJoined, OnClientLeaved, OnMessageRecieved);
	if (pModelOrNull == nullptr)
	{
		return 1;
	}

	RunServer(pModelOrNull);

	DanbiNetworkSelect::Finalize(pModelOrNull);

	return 0;
}

int RunServer(DanbiNetworkSelect::Model* const pModel)
{
	for (;;)
	{
		DanbiNetworkSelect::Update(pModel);
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