#pragma once

#include "Types.h"

#ifdef _WINDLL
#define EXPORT_NETWORK_DLL_API __declspec(dllexport)
#else
#define EXPORT_NETWORK_DLL_API __declspec(dllimport)
#endif

class SerializedBuffer;

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
		const uint32_t sendRingBufferCapacity,
		const uint32_t recvRingBufferCapacity,
		const size_t serializedBufferMessageCapacity,
		bool (*pOnClientJoined)(const SESSION_ID sessionId),
		void (*pOnClientLeaved)(const SESSION_ID sessionId),
		bool (*pOnMessageReceived)(const SESSION_ID sessionId, const MESSAGE_TYPE type, SerializedBuffer& msg)
	);

	extern "C" EXPORT_NETWORK_DLL_API
	void Destroy(Instance** const ppInstance);

	extern "C" EXPORT_NETWORK_DLL_API
	void Update(Instance* const pInstance);
}