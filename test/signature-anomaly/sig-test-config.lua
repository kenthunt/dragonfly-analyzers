-- ----------------------------------------------
-- Copyright (c) 2019, CounterFlow AI, Inc. All Rights Reserved.
-- Author: Andrew Fast <af@counterflowai.com>
--
-- Use of this source code is governed by a BSD-style
-- license that can be found in the LICENSE.txt file.
-- ----------------------------------------------


-- -----------------------------------------------------------
-- redis parameters
-- -----------------------------------------------------------
redis_host = "127.0.0.1"
redis_port = "6379"

-- -----------------------------------------------------------
-- Input queues/processors
-- -----------------------------------------------------------
inputs = {
   { tag="eve", uri="file:///usr/local/mle-data/sig-test-data.json", script="sig-test-filter.lua", default_analyzer="signature"}, --Split messages based on type
}

-- -----------------------------------------------------------
-- Analyzer queues/processors
-- -----------------------------------------------------------
analyzers = {
   { tag="signature", script="signature-anomaly.lua", default_analyzer="sink", default_output="log"},
   { tag="sink", script="write-to-log.lua", default_analyzer="", default_output="log"},
}

-- -----------------------------------------------------------
-- Output queues/processors
-- -----------------------------------------------------------
outputs = {
    { tag="log", uri="file://dragonfly-sig-test.log"},
}

