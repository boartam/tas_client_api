Remove-Item -Recurse -Force build-linux -ErrorAction SilentlyContinue
cmake -S . -B build-linux -G Ninja  -DCMAKE_TOOLCHAIN_FILE="cmake/toolchains/linux-cross-zig.cmake"  -DCMAKE_BUILD_TYPE=Release  -DCMAKE_GENERATOR_INSTANCE=
cmake --build build-linux --target tas_socket -j $env:NUMBER_OF_PROCESSORS
cmake --build build-linux --target tas_client -j $env:NUMBER_OF_PROCESSORS
cmake --build build-linux --target tas_chl_api_demo tas_rw_api_demo -j $env:NUMBER_OF_PROCESSORS


#for PxTAS but not working on windows.
cmake -S . -B build-linux -G Ninja -DCMAKE_TOOLCHAIN_FILE="cmake/toolchains/linux-cross-zig.cmake" -DTAS_CLIENT_API_FORCE_PYTHON=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build-linux --target PyTAS -j $env:NUMBER_OF_PROCESSORS