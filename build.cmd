
g++ -DNDEBUG -DDLL_EXPORT -DPIC -DHAVE_CONFIG_H -Isrc -O3 -flto -fdata-sections -ffunction-sections -c src\city.cc -o bin\city.o
g++ -Wl,--gc-sections -Wl,--print-gc-sections -O3 -flto -fPIC -s -shared -static-libgcc -o bin\CityHash.dll bin\city.o -lm -Wl,--out-implib,bin\CityHash.dll.a,--output-def,bin\CityHash.def

pause