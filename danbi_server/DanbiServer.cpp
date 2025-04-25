#include "DanbiNetworkSelect.h"
#include "Types.h"

#pragma comment(lib,"./DanbiNetworkSelect.lib")

int RunServer(void);
bool OnClientJoined(const SESSION_ID sessionId);
void OnClientLeaved(const SESSION_ID sessionId);
void OnMessageRecieved(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData);

int wmain()
{
	DanbiNetworkSelect::eInitMode initMode;

	initMode = DanbiNetworkSelect::Initialize(L"0.0.0.0", 9000, 1, 65535, 1, true, OnClientJoined, OnClientLeaved, OnMessageRecieved);
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