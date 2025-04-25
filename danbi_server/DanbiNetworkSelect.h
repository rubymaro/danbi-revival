#pragma once

#include "Types.h"

#ifdef _WINDLL
#define NETWORK_DLL_API __declspec(dllexport)
#else
#define NETWORK_DLL_API __declspec(dllimport)
#endif

namespace DanbiNetworkSelect
{
	enum class eInitMode
	{
		INIT_BEFORE,
		INIT_SUCCESS,
		INIT_FAILED,
	};

	extern "C" NETWORK_DLL_API
	eInitMode Initialize(
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
		void (*pOnMessageRecieved)(const SESSION_ID sessionId, const uint32_t cbRecv, const char* const pData)
	);

	extern "C" NETWORK_DLL_API
	void Finalize(void);

	extern int gTcpNoDelay;
	extern size_t gSendRingBufferCapacity;
	extern size_t gRecvRingBufferCapacity;
}