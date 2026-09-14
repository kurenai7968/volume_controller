#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>

#include <memory>
#include <string>

#include "volume_controller_plugin.h"

namespace volume_controller
{
  namespace test
  {

    TEST(VolumeControllerPlugin, SetVolumeMissingArgumentReturnsError)
    {
      VolumeControllerPlugin plugin;
      std::string error_code;

      plugin.HandleMethodCall(
          flutter::MethodCall<flutter::EncodableValue>(
              "setVolume", std::make_unique<flutter::EncodableValue>()),
          std::make_unique<flutter::MethodResultFunctions<>>(
              nullptr,
              [&error_code](const std::string &code, const std::string &,
                            const flutter::EncodableValue *)
              {
                error_code = code;
              },
              nullptr));

      EXPECT_EQ(error_code, "InvalidArguments");
    }

    TEST(VolumeControllerPlugin, SetMuteMissingArgumentReturnsError)
    {
      VolumeControllerPlugin plugin;
      std::string error_code;

      plugin.HandleMethodCall(
          flutter::MethodCall<flutter::EncodableValue>(
              "setMute", std::make_unique<flutter::EncodableValue>()),
          std::make_unique<flutter::MethodResultFunctions<>>(
              nullptr,
              [&error_code](const std::string &code, const std::string &,
                            const flutter::EncodableValue *)
              {
                error_code = code;
              },
              nullptr));

      EXPECT_EQ(error_code, "InvalidArguments");
    }

  } // namespace test
} // namespace volume_controller
