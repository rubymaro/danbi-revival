#pragma once

#include "Types.h"

#ifdef _WINDLL
#define EXPORT_NETWORK_DLL_API __declspec(dllexport)
#else
#define EXPORT_NETWORK_DLL_API __declspec(dllimport)
#endif

namespace DanbiNetworkSelect
{
	struct Instance;

	extern "C" EXPORT_NETWORK_DLL_API
	Instance* CreateOrNull(
		const wchar_t* const lpListenSocketIpV4,
		const unsigned short listenSocketTcpPort,
		const unsigned long nonBlockingMode,
		const int maxBacklog,
		const unsigned int uPeriod,
		const bool bTcpNoDelay,
		const size_t sendRingBufferCapacity,
		const size_t recvRingBufferCapacity,
		bool (*pOnClientJoined)(const SESSION_ID sessionId),
		void (*pOnClientLeaved)(const SESSION_ID sessionId),
		void (*pOnMessageRecieved)(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pMessage)
	);

	extern "C" EXPORT_NETWORK_DLL_API
	void Finalize(Instance* const pModel);

	extern "C" EXPORT_NETWORK_DLL_API
	void Update(Instance* const pModel);
}