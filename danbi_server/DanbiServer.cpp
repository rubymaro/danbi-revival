#include "DanbiServer.h"

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
	return true;
}

void DanbiServer::OnClientLeaved(const SESSION_ID sessionId)
{

}

bool DanbiServer::OnMessageReceived(const SESSION_ID sessionId, const MESSAGE_TYPE type, SerializedBuffer& msg)
{
	return true;
}