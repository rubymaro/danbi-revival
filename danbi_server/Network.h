#pragma once

#ifdef _WINDLL
#define NETWORK_DLL_API __declspec(dllexport)
#else
#define NETWORK_DLL_API __declspec(dllimport)
#endif

extern "C" NETWORK_DLL_API
int InitializeNetwork(
	const wchar_t* const lpListenSocketIpV4,
	const unsigned short listenSocketTcpPort,
	const int maxBacklog,
	const unsigned int uPeriod,
	const bool bTcpNoDelay
);