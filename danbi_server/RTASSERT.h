#ifdef RUNTIME_ASSERT
#define RTASSERT(boolExpr) \
	do { \
		if (!(boolExpr)) \
		{ \
			__debugbreak(); \
		} \
	} while (0)
#else
#define RTASSERT(boolExpr) __assume(boolExpr)
#endif