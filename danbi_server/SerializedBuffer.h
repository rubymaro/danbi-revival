#pragma once

#include "RTASSERT.h"

class SerializedBuffer final
{
	enum
	{
		DEFAULT_CAPACITY = 1400,
		MAX_RESIZE_COUNT = 2,
	};

public:
	enum class eError : unsigned int
	{
		None = 0,
		CannotWrite = 1,
		CannotRead = 2,
	};

	inline SerializedBuffer(void);
	inline SerializedBuffer(const size_t capacity);
	inline SerializedBuffer(const SerializedBuffer& other);
	inline SerializedBuffer(SerializedBuffer&& other) = delete;
	inline ~SerializedBuffer(void);

	inline SerializedBuffer& operator=(const SerializedBuffer& other);
	inline SerializedBuffer&& operator=(SerializedBuffer&& other) = delete;

	inline SerializedBuffer& operator<<(const char chValue);
	inline SerializedBuffer& operator<<(const unsigned char uchValue);
	inline SerializedBuffer& operator<<(const short shValue);
	inline SerializedBuffer& operator<<(const unsigned short ushValue);
	inline SerializedBuffer& operator<<(const int iValue);
	inline SerializedBuffer& operator<<(const unsigned int uiValue);
	inline SerializedBuffer& operator<<(const long lValue);
	inline SerializedBuffer& operator<<(const unsigned long ulValue);
	inline SerializedBuffer& operator<<(const long long llValue);
	inline SerializedBuffer& operator<<(const unsigned long long ullValue);
	inline SerializedBuffer& operator<<(const float fValue);
	inline SerializedBuffer& operator<<(const double dValue);

	inline SerializedBuffer& operator>>(char& outChValue);
	inline SerializedBuffer& operator>>(unsigned char& outUchValue);
	inline SerializedBuffer& operator>>(short& outShValue);
	inline SerializedBuffer& operator>>(unsigned short& outUshValue);
	inline SerializedBuffer& operator>>(int& outIValue);
	inline SerializedBuffer& operator>>(unsigned int& outUiValue);
	inline SerializedBuffer& operator>>(long& outLValue);
	inline SerializedBuffer& operator>>(unsigned long& outUlValue);
	inline SerializedBuffer& operator>>(long long& outLlValue);
	inline SerializedBuffer& operator>>(unsigned long long& outUllValue);
	inline SerializedBuffer& operator>>(float& outFValue);
	inline SerializedBuffer& operator>>(double& outDbValue);

	inline size_t Capacity(void) const;
	inline size_t Size(void) const;
	inline const char* BufferPtr(void) const;
	inline bool IsWriteError(void) const;
	inline bool IsReadError(void) const;

	inline bool MoveReadPos(const size_t size);
	inline bool MoveWritePos(const size_t size);
	inline bool Get(void* const pOutDstStart, const size_t dstSize);
	inline bool Put(const void* const pSrcStart, const size_t srcSize);
	inline void Clear(void);

private:
	inline bool tryResizeToBiggerCapacity(void);

	char* mpaBuffer;
	size_t mCapacity;
	char* mpReadPos;
	char* mpWritePos;
	char* mpBufferEnd;
	unsigned int mResizeCount;
	eError mError;
};

// SerializedBuffer definitions

SerializedBuffer::SerializedBuffer(void)
	: SerializedBuffer(DEFAULT_CAPACITY)
{
}

SerializedBuffer::SerializedBuffer(const size_t capacity)
	: mpaBuffer(nullptr)
	, mCapacity(capacity)
	, mpReadPos(nullptr)
	, mpWritePos(nullptr)
	, mpBufferEnd(nullptr)
	, mResizeCount(0)
	, mError(eError::None)
{
	RTASSERT(capacity > 0);

	if (mCapacity > 0)
	{
		mpaBuffer = new char[mCapacity];
		mpReadPos = mpaBuffer;
		mpWritePos = mpaBuffer;
		mpBufferEnd = &mpaBuffer[mCapacity];
	}
}

SerializedBuffer::SerializedBuffer(const SerializedBuffer& other)
	: mpaBuffer(nullptr)
	, mCapacity(other.mCapacity)
	, mpReadPos(nullptr)
	, mpWritePos(nullptr)
	, mpBufferEnd(nullptr)
	, mResizeCount(other.mResizeCount)
	, mError(other.mError)
{
	const char* pPosSrc;
	char* pPosDst;

	if (mCapacity > 0)
	{
		mpaBuffer = new char[mCapacity];
		mpReadPos = &mpaBuffer[other.mpReadPos - other.mpaBuffer];
		mpWritePos = &mpaBuffer[other.mpWritePos - other.mpaBuffer];
		mpBufferEnd = &mpaBuffer[mCapacity];

		pPosSrc = other.mpReadPos;
		pPosDst = mpReadPos;
		while (pPosDst < mpWritePos)
		{
			*pPosDst++ = *pPosSrc++;
		}
	}
}

SerializedBuffer::~SerializedBuffer(void)
{
	delete[] mpaBuffer;
	mpaBuffer = nullptr;
}

SerializedBuffer& SerializedBuffer::operator=(const SerializedBuffer& other)
{
	const char* pPosSrc;
	char* pPosDst;

	if (this != &other)
	{
		delete[] mpaBuffer;

		mCapacity = other.mCapacity;
		mpaBuffer = new char[mCapacity];
		mpReadPos = &mpaBuffer[other.mpReadPos - other.mpaBuffer];
		mpWritePos = &mpaBuffer[other.mpWritePos - other.mpaBuffer];
		mpBufferEnd = &mpaBuffer[other.mCapacity];
		mResizeCount = other.mResizeCount;
		mError = other.mError;

		pPosSrc = other.mpReadPos;
		pPosDst = mpReadPos;
		while (pPosDst < mpWritePos)
		{
			*pPosDst++ = *pPosSrc++;
		}
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const char chValue)
{
	while (mpWritePos + sizeof(chValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*mpWritePos = chValue;
	mpWritePos += sizeof(chValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const unsigned char uchValue)
{
	while (mpWritePos + sizeof(uchValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<unsigned char*>(mpWritePos) = uchValue;
	mpWritePos += sizeof(uchValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const short shValue)
{
	while (mpWritePos + sizeof(shValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<short*>(mpWritePos) = shValue;
	mpWritePos += sizeof(shValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const unsigned short ushValue)
{
	while (mpWritePos + sizeof(ushValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<unsigned short*>(mpWritePos) = ushValue;
	mpWritePos += sizeof(ushValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const int iValue)
{
	while (mpWritePos + sizeof(iValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<int*>(mpWritePos) = iValue;
	mpWritePos += sizeof(iValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const unsigned int uiValue)
{
	while (mpWritePos + sizeof(uiValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<unsigned int*>(mpWritePos) = uiValue;
	mpWritePos += sizeof(uiValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const long lValue)
{
	while (mpWritePos + sizeof(lValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<long*>(mpWritePos) = lValue;
	mpWritePos += sizeof(lValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const unsigned long ulValue)
{
	while (mpWritePos + sizeof(ulValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<unsigned long*>(mpWritePos) = ulValue;
	mpWritePos += sizeof(ulValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const long long llValue)
{
	while (mpWritePos + sizeof(llValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<long long*>(mpWritePos) = llValue;
	mpWritePos += sizeof(llValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const unsigned long long ullValue)
{
	while (mpWritePos + sizeof(ullValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<unsigned long long*>(mpWritePos) = ullValue;
	mpWritePos += sizeof(ullValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const float fValue)
{
	while (mpWritePos + sizeof(fValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<float*>(mpWritePos) = fValue;
	mpWritePos += sizeof(fValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator<<(const double dbValue)
{
	while (mpWritePos + sizeof(dbValue) > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return *this;
		}
	}

	*reinterpret_cast<double*>(mpWritePos) = dbValue;
	mpWritePos += sizeof(dbValue);

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(char& outChValue)
{
	if (mpReadPos + sizeof(outChValue) <= mpWritePos)
	{
		outChValue = *mpReadPos;
		mpReadPos += sizeof(outChValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(unsigned char& outUchValue)
{
	if (mpReadPos + sizeof(outUchValue) <= mpWritePos)
	{
		outUchValue = *reinterpret_cast<unsigned char*>(mpReadPos);
		mpReadPos += sizeof(outUchValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(short& outShValue)
{
	if (mpReadPos + sizeof(outShValue) <= mpWritePos)
	{
		outShValue = *reinterpret_cast<short*>(mpReadPos);
		mpReadPos += sizeof(outShValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(unsigned short& outUshValue)
{
	if (mpReadPos + sizeof(outUshValue) <= mpWritePos)
	{
		outUshValue = *reinterpret_cast<unsigned short*>(mpReadPos);
		mpReadPos += sizeof(outUshValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(int& outIValue)
{
	if (mpReadPos + sizeof(outIValue) <= mpWritePos)
	{
		outIValue = *reinterpret_cast<int*>(mpReadPos);
		mpReadPos += sizeof(outIValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(unsigned int& outUiValue)
{
	if (mpReadPos + sizeof(outUiValue) <= mpWritePos)
	{
		outUiValue = *reinterpret_cast<unsigned int*>(mpReadPos);
		mpReadPos += sizeof(outUiValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(long& outLValue)
{
	if (mpReadPos + sizeof(outLValue) <= mpWritePos)
	{
		outLValue = *reinterpret_cast<long*>(mpReadPos);
		mpReadPos += sizeof(outLValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(unsigned long& outUlValue)
{
	if (mpReadPos + sizeof(outUlValue) <= mpWritePos)
	{
		outUlValue = *reinterpret_cast<unsigned long*>(mpReadPos);
		mpReadPos += sizeof(outUlValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(long long& outLlValue)
{
	if (mpReadPos + sizeof(outLlValue) <= mpWritePos)
	{
		outLlValue = *reinterpret_cast<long long*>(mpReadPos);
		mpReadPos += sizeof(outLlValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(unsigned long long& outUllValue)
{
	if (mpReadPos + sizeof(outUllValue) <= mpWritePos)
	{
		outUllValue = *reinterpret_cast<unsigned long long*>(mpReadPos);
		mpReadPos += sizeof(outUllValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(float& outFValue)
{
	if (mpReadPos + sizeof(outFValue) <= mpWritePos)
	{
		outFValue = *reinterpret_cast<float*>(mpReadPos);
		mpReadPos += sizeof(outFValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

SerializedBuffer& SerializedBuffer::operator>>(double& outDbValue)
{
	if (mpReadPos + sizeof(outDbValue) <= mpWritePos)
	{
		outDbValue = *reinterpret_cast<double*>(mpReadPos);
		mpReadPos += sizeof(outDbValue);
	}
	else
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
	}

	return *this;
}

size_t SerializedBuffer::Capacity(void) const
{
	return mCapacity;
}

size_t SerializedBuffer::Size(void) const
{
	return mpWritePos - mpReadPos;
}

const char* SerializedBuffer::BufferPtr(void) const
{
	return mpaBuffer;
}

inline bool SerializedBuffer::IsWriteError(void) const
{
	return static_cast<unsigned int>(mError) & static_cast<unsigned int>(eError::CannotWrite);
}

inline bool SerializedBuffer::IsReadError(void) const
{
	return static_cast<unsigned int>(mError) & static_cast<unsigned int>(eError::CannotRead);
}

bool SerializedBuffer::MoveReadPos(const size_t size)
{
	RTASSERT(size > 0);

	if (&mpReadPos[size] > mpWritePos)
	{
		return false;
	}

	mpReadPos += size;

	return true;
}

bool SerializedBuffer::MoveWritePos(const size_t size)
{
	RTASSERT(size > 0);

	if (&mpWritePos[size] > mpBufferEnd)
	{
		return false;
	}

	mpWritePos += size;

	return true;
}

bool SerializedBuffer::Get(void* const pOutDstStart, const size_t dstSize)
{
	RTASSERT(pOutDstStart != nullptr);
	RTASSERT(dstSize > 0);

	const char* pSrcPos = mpReadPos;
	char* pDstPos = reinterpret_cast<char*>(pOutDstStart);

	if (mpReadPos + dstSize > mpWritePos)
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotRead));
		return false;
	}

	mpReadPos += dstSize;

	while (pSrcPos < mpReadPos)
	{
		*pDstPos++ = *pSrcPos++;
	}

	return true;
}

bool SerializedBuffer::Put(const void* const pSrcStart, const size_t srcSize)
{
	RTASSERT(pSrcStart != nullptr);
	RTASSERT(srcSize > 0);

	const char* pSrcPos;
	char* pDstPos;

	while (mpWritePos + srcSize > mpBufferEnd)
	{
		if (!tryResizeToBiggerCapacity())
		{
			return false;
		}
	}

	pSrcPos = reinterpret_cast<const char*>(pSrcStart);
	pDstPos = mpWritePos;
	mpWritePos += srcSize;

	while (pDstPos < mpWritePos)
	{
		*pDstPos++ = *pSrcPos++;
	}

	return true;
}

void SerializedBuffer::Clear(void)
{
	mpReadPos = mpaBuffer;
	mpWritePos = mpaBuffer;
	mError = eError::None;
}

bool SerializedBuffer::tryResizeToBiggerCapacity(void)
{
	char* paNewBigBuffer;
	const char* pSrcPos;
	char* pDstPos;

	if (mResizeCount >= MAX_RESIZE_COUNT)
	{
		mError = static_cast<eError>(static_cast<unsigned int>(mError) | static_cast<unsigned int>(eError::CannotWrite));
		return false;
	}

	++mResizeCount;

	mCapacity *= 2;
	paNewBigBuffer = new char[mCapacity];
	RTASSERT(paNewBigBuffer != nullptr);

	pSrcPos = mpReadPos;
	pDstPos = paNewBigBuffer;
	while (pSrcPos < mpWritePos)
	{
		*pDstPos++ = *pSrcPos++;
	}

	mpReadPos = &paNewBigBuffer[mpReadPos - mpaBuffer];
	mpWritePos = &paNewBigBuffer[mpWritePos - mpaBuffer];
	mpBufferEnd = &paNewBigBuffer[mCapacity];

	delete[] mpaBuffer;
	mpaBuffer = paNewBigBuffer;

	return true;
}
