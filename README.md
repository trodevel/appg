# APPG - automatic protocol parser generator

Generates protocol parser, validator, visualizer from the formal description of protocol objects.


## Features

- Perl implementation
- generates C++ and PHP code
- generates test protocol messages
- generates message validator
- support of protocol inheritance

## Features of the generated C++ code

- definition of objects
- parser of key/value requests
- serialization of objects to CSV
- conversion of objects to strings
- validation of objects

## Features of the generated PHP code

- definition of objects
- serialization of objects to key/value requests
- parser of the serialized CSV objects
- conversion of objects to strings
- conversion of objects to HTML

## Requirements

- Perl5
- boost system, date_time
- for C++ code: anyvalue utils scheduler make_tools

## Example


### generate code (C++ and PHP)

``` bash
cd appg
./code_gen.pl --input_file example.prt --output_file a.h
```

### C++: Check out all required libraries and build


``` bash
git clone https://github.com/trodevel/basic_parser.git
git clone https://github.com/trodevel/generic_request.git
git clone https://github.com/trodevel/make_tools.git
git clone https://github.com/trodevel/utils.git
export BOOST_PATH=...your_boost_directory...
```

### C++: build generated project

``` bash
git clone https://github.com/trodevel/appg.git
cd appg
./code_gen.pl --input_file example_01_basic.prt --output_file a.h
make
```

### C++: execute example

``` bash
./example
```

## TODOs

- generate C++ and PHP code optionally
- write generated files into a separate directory

## Contact info

I'll appreciate your feedback. Please feel free to contact me at trodevel@gmail.com. Thanks!

Dr. Sergey Kolevatov

