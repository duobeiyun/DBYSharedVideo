#!/bin/bash
BUILD_DIR="build"
schemes="DBYSDK_dylib"
workspace_name="DBYSharedVideoDemo.xcworkspace"

universal_dir="${BUILD_DIR}/universal"
iphoneos_dir="${BUILD_DIR}/Release-iphoneos"
iphonesimulator_dir="${BUILD_DIR}/Debug-iphonesimulator"

makeBuildDir(){
    if [ ! -d $BUILD_DIR ]
    then
        mkdir $BUILD_DIR
    fi
}
cleanBuildDir(){
    if [ -d $BUILD_DIR ]
    then
    rm -rf $BUILD_DIR
    fi
}
mergeFramework(){
    if [ ! -d "${universal_dir}" ]
    then
        mkdir -p "${universal_dir}"
    fi
    for scheme in ${schemes}
    do
      echo "${scheme}"
      cp -rf "${iphoneos_dir}/${scheme}/${scheme}.framework" "${universal_dir}"
      lipo -create "${iphonesimulator_dir}/${scheme}/${scheme}.framework/${scheme}" "${iphoneos_dir}/${scheme}/${scheme}.framework/${scheme}" -output "${universal_dir}/${scheme}.framework/${scheme}"
    done
}
buildAll() {
    for scheme in ${schemes}
    do
      echo ${scheme}
      xcodebuild -workspace "${workspace_name}" -scheme "${scheme}" ONLY_ACTIVE_ARCH=NO VALID_ARCHS='x86_64' -sdk iphonesimulator BUILD_DIR="../${BUILD_DIR}" clean build
      xcodebuild -workspace "${workspace_name}" -scheme "${scheme}" ONLY_ACTIVE_ARCH=NO -configuration 'Release' VALID_ARCHS='arm64 armv7' -sdk iphoneos BUILD_DIR="../${BUILD_DIR}" clean build
    done
}
buildFramework(){
    makeBuildDir
    cleanBuildDir
    buildAll
    mergeFramework
}
buildFramework





