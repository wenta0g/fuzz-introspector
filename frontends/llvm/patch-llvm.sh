#!/bin/bash -eu
# Copyright 2022 Fuzz Introspector Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
set -x

if [ -f ./llvm/lib/Transforms/IPO/PassManagerBuilder.cpp ]; then
    echo "Applying llvm 14 pathes"
    echo "add_subdirectory(FuzzIntrospector)" >> ./llvm/lib/Transforms/CMakeLists.txt
    sed 's/whole-program devirtualization and bitset lowering./whole-program devirtualization and bitset lowering.\nPM.add(createFuzzIntrospectorPass());/g' ./llvm/lib/Transforms/IPO/PassManagerBuilder.cpp > tmp; cat tmp > ./llvm/lib/Transforms/IPO/PassManagerBuilder.cpp; rm tmp
    sed 's/using namespace/#include "llvm\/Transforms\/FuzzIntrospector\/FuzzIntrospector.h"\nusing namespace/g' ./llvm/lib/Transforms/IPO/PassManagerBuilder.cpp > tmp; cat tmp > ./llvm/lib/Transforms/IPO/PassManagerBuilder.cpp; rm tmp
    sed  's/Instrumentation/Instrumentation\n  FuzzIntrospector/g' ./llvm/lib/Transforms/IPO/CMakeLists.txt > tmp; cat tmp > ./llvm/lib/Transforms/IPO/CMakeLists.txt; rm tmp

    sed  's/void initializeCrossDSOCFIPass(PassRegistry\&);/void initializeCrossDSOCFIPass(PassRegistry\&);\nvoid initializeFuzzIntrospectorPass(PassRegistry\&);/g' ./llvm/include/llvm/InitializePasses.h > tmp; cat tmp > ./llvm/include/llvm/InitializePasses.h; rm tmp
    sed  's/#include "llvm\/Transforms\/Instrumentation\/ThreadSanitizer.h"/#include "llvm\/Transforms\/Instrumentation\/ThreadSanitizer.h"\n#include "llvm\/Transforms\/FuzzIntrospector\/FuzzIntrospector.h"/g' ./llvm/lib/Passes/PassBuilder.cpp > tmp; cat tmp > ./llvm/lib/Passes/PassBuilder.cpp; rm tmp
    sed  's/#include "llvm\/Transforms\/Instrumentation\/PGOInstrumentation.h"/#include "llvm\/Transforms\/Instrumentation\/PGOInstrumentation.h"\n#include "llvm\/Transforms\/FuzzIntrospector\/FuzzIntrospector.h"/g' ./llvm/lib/Passes/PassBuilderPipelines.cpp > tmp; cat tmp > ./llvm/lib/Passes/PassBuilderPipelines.cpp; rm tmp
    sed  's/MPM.addPass(CrossDSOCFIPass());/MPM.addPass(CrossDSOCFIPass());\n  MPM.addPass(FuzzIntrospectorPass());/g' ./llvm/lib/Passes/PassBuilderPipelines.cpp > tmp; cat tmp > ./llvm/lib/Passes/PassBuilderPipelines.cpp; rm tmp
    sed  's/MODULE_PASS("annotation2metadata", Annotation2MetadataPass())/MODULE_PASS("annotation2metadata", Annotation2MetadataPass())\nMODULE_PASS("fuzz-introspector", FuzzIntrospectorPass())/g' ./llvm/lib/Passes/PassRegistry.def > tmp; cat tmp > ./llvm/lib/Passes/PassRegistry.def; rm tmp
else
    echo "Applying llvm 18 pathes"
    echo "add_subdirectory(FuzzIntrospector)" >> ./llvm/lib/Transforms/CMakeLists.txt
    sed -i 's/Instrumentation/Instrumentation\n  FuzzIntrospector/g' ./llvm/lib/Transforms/IPO/CMakeLists.txt

    sed -i 's/void initializeXRayInstrumentationPass(PassRegistry\&);/void initializeXRayInstrumentationPass(PassRegistry\&);\nvoid initializeFuzzIntrospectorPass(PassRegistry\&);/g' ./llvm/include/llvm/InitializePasses.h
    sed -i 's/#include "llvm\/Transforms\/Instrumentation\/ThreadSanitizer.h"/#include "llvm\/Transforms\/Instrumentation\/ThreadSanitizer.h"\n#include "llvm\/Transforms\/FuzzIntrospector\/FuzzIntrospector.h"/g' ./llvm/lib/Passes/PassBuilder.cpp
    sed -i 's/#include "llvm\/Transforms\/Instrumentation\/PGOInstrumentation.h"/#include "llvm\/Transforms\/Instrumentation\/PGOInstrumentation.h"\n#include "llvm\/Transforms\/FuzzIntrospector\/FuzzIntrospector.h"/g' ./llvm/lib/Passes/PassBuilderPipelines.cpp
    sed -i 's/MPM.addPass(CrossDSOCFIPass());/MPM.addPass(CrossDSOCFIPass());\n  MPM.addPass(FuzzIntrospectorPass());/g' ./llvm/lib/Passes/PassBuilderPipelines.cpp
    sed -i 's/MODULE_PASS("annotation2metadata", Annotation2MetadataPass())/MODULE_PASS("annotation2metadata", Annotation2MetadataPass())\nMODULE_PASS("fuzz-introspector", FuzzIntrospectorPass())/g' ./llvm/lib/Passes/PassRegistry.def
fi
