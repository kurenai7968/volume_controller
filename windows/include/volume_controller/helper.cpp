#include "helper.h"

namespace volume_controller
{
    const flutter::EncodableValue *GetArgValue(const flutter::EncodableMap &map, const char *key)
    {
        auto it = map.find(flutter::EncodableValue(key));
        if (it == map.end())
        {
            return nullptr;
        }
        return &(it->second);
    }
}