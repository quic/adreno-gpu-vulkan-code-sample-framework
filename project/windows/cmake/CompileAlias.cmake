#
# Parse and build shader alias
#
# Inputs:
#   INPUT_ALIAS
#   OUTPUT_SHADER
#   OUTPUT_SHADER_DEP

file(READ ${INPUT_ALIAS} ALIAS_JSON)

string(JSON INPUT_SHADER GET ${ALIAS_JSON} Shader)
string(JSON INPUT_DEFINES GET ${ALIAS_JSON} Defines)
string(JSON TARGET_ENV ERROR_VARIABLE JSON_ERROR GET ${ALIAS_JSON} TargetEnv ${ALIAS_JSON})
if(NOT ${JSON_ERROR} EQUAL "NOTFOUND")
    set(TARGET_ENV "vulkan1.1")
endif()

# expand out the "Defines: []" JSON array
set(DEFINES "")
string(JSON INPUT_DEFINES_COUNT LENGTH ${INPUT_DEFINES})
if(INPUT_DEFINES_COUNT GREATER 0)
    math(EXPR INPUT_DEFINES_COUNT "${INPUT_DEFINES_COUNT} - 1")
    foreach(DEFINE_IDX RANGE ${INPUT_DEFINES_COUNT})
      string(JSON DEFINE GET ${INPUT_DEFINES} ${DEFINE_IDX})
      list(APPEND DEFINES "-D${DEFINE}")
    endforeach()
endif()

message("Defines ${DEFINES}")

cmake_path(REMOVE_FILENAME INPUT_ALIAS OUTPUT_VARIABLE INPUT_ALIAS_PATH)
cmake_path(APPEND I ${INPUT_ALIAS_PATH} ${INPUT_SHADER})
set(INPUT_SHADER ${I})

#message("Shader ${INPUT_SHADER}")
#message("Defines ${INPUT_DEFINES}")
#message("GLSL_VALIDATOR ${GLSL_VALIDATOR}")

execute_process(
    COMMAND ${GLSL_VALIDATOR} ${SHADER_INCLUDE} -I. -V --quiet --target-env ${TARGET_ENV} ${DEFINES} ${INPUT_SHADER} -o ${OUTPUT_SHADER} --depfile ${OUTPUT_SHADER_DEP}
    #COMMAND_ECHO STDOUT
    COMMAND_ERROR_IS_FATAL ANY
)
