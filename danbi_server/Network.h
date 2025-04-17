#pragma once

#ifdef _WINDLL
#define NETWORK_DLL_API __declspec(dllexport)
#else
#define NETWORK_DLL_API __declspec(dllimport)
#endif

extern "C" NETWORK_DLL_API void InitializeHandlers();