/*
 * Copyright 2016 Gary R. Van Sickle (grvs@users.sourceforge.net).
 *
 * This file is part of UniversalCodeGrep.
 *
 * UniversalCodeGrep is free software: you can redistribute it and/or modify it under the
 * terms of version 3 of the GNU General Public License as published by the Free
 * Software Foundation.
 *
 * UniversalCodeGrep is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * UniversalCodeGrep.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SRC_RESIZABLEARRAY_H_
#define SRC_RESIZABLEARRAY_H_

#include <new>

/**
 * This is sort of a poor-man's std::allocator<>, without the std.  We use it in the File() constructor
 * to get a buffer to read the file data into.  By instantiating one of these objects prior to a loop of
 * File() constructions, we will simply recycle the same buffer unless we need a larger one, instead of
 * deleting/newing a brand-new buffer for every file we read in.  This can reduce allocation traffic considerably.
 * See FileScanner::Run() for this sort of usage.
 */
template<typename T>
class ResizableArray
{
public:
	ResizableArray() noexcept = default;
	~ResizableArray() noexcept
	{
		if(m_current_buffer!=nullptr)
		{
			::operator delete(m_current_buffer);
		}
	};

	T * data() const noexcept { return m_current_buffer; };

	void reserve_no_copy(std::size_t needed_size)
	{
		if(m_current_buffer==nullptr || m_current_buffer_size < needed_size)
		{
			// Need to allocate a new raw buffer.
			if(m_current_buffer!=nullptr)
			{
				::operator delete(m_current_buffer);
			}

			m_current_buffer_size = needed_size;
			m_current_buffer = static_cast<T*>(::operator new(m_current_buffer_size*sizeof(T)));
		}
	}

private:

	std::size_t m_current_buffer_size { 0 };
	T *m_current_buffer { nullptr };
};

#endif /* SRC_RESIZABLEARRAY_H_ */