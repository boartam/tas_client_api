param(
    [string[]]$PythonTags = @("cp311-cp311", "cp312-cp312"),
    [string]$Image = "quay.io/pypa/manylinux2014_x86_64"
)

$ErrorActionPreference = "Stop"

Write-Host "Pulling manylinux image $Image" -ForegroundColor Cyan
docker pull $Image

$repo = (Resolve-Path ".").Path

$script = @'
set -euxo pipefail
for PYTAG in $PYTAGS; do
  PYBIN=/opt/python/${PYTAG}/bin/python
  $PYBIN -m pip install --upgrade pip
  $PYBIN -m pip install cmake ninja pybind11 setuptools wheel auditwheel
  if [ -f /opt/rh/devtoolset-10/enable ]; then source /opt/rh/devtoolset-10/enable; elif [ -f /opt/rh/devtoolset-9/enable ]; then source /opt/rh/devtoolset-9/enable; fi
  export PATH="$(dirname "$PYBIN"):$PATH"
  gcc --version || true
  cmake --version || true
  ninja --version || true
  P11_DIR=$($PYBIN -c "import pybind11,sys; print(pybind11.get_cmake_dir())")
  VTAG=$(python -c "print('${PYTAG}')")
  BUILD_DIR=/work/build-${VTAG}
  cmake -S /work -B ${BUILD_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DTAS_CLIENT_API_BUILD_PYTHON=ON -DPython_EXECUTABLE=$PYBIN -Dpybind11_DIR="$P11_DIR"
  cmake --build ${BUILD_DIR} --target python_package -j$(nproc)
  mkdir -p /work/dist
  auditwheel repair -w /work/dist ${BUILD_DIR}/python/dist/*.whl || true
done
'@

$tags = $PythonTags -join " "

Write-Host "Building wheels for: $tags" -ForegroundColor Cyan

docker run --rm -v "$repo:/work" -w /work $Image /bin/bash -lc "PYTAGS='$tags' $script"

Write-Host "Done. Wheels in ./dist" -ForegroundColor Green
