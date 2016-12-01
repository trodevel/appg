/*

JSON helper functions.

Copyright (C) 2016 Sergey Kolevatov

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

*/

// $Revision: 5100 $ $Date:: 2016-11-30 #$ $Author: serge $

#ifndef APG_JSON_HELPER_H
#define APG_JSON_HELPER_H

#include <iostream>         // std::istream
#include <string>           // std::string
#include <vector>           // std::vector
#include <map>              // std::map
#include <cstdint>          // uint32_t

namespace json_helper
{

inline std::string tabulate( const std::string & s )
{
    std::ostringstream os;
    std::istringstream is( s );

    std::string line;
    while( std::getline( is, line ) )
    {
        os << "    " << line << "\n";
    }

    return os.str()
}

inline std::string bracketize( const std::string & s )
{
    return "{\n" + tabulate( s ) + "}\n";
}

inline std::string quote( const std::string & s )
{
    return "\"" + s + "\"";
}

inline std::string to_string( const std::string & s )
{
    return quote( s );
}

template <class C>
inline std::string to_pair( const std::string & k, const C & v, bool is_last_elem = false )
{
    std::ostringstream os;

    os << quote( k ) << ": " << v;

    if( is_last_elem == false )
    {
        os << ",";
    }

    os << "\n";

    return os.str()
}

} // namespace json_helper

#endif // APG_JSON_HELPER_H
