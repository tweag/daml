// Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

import * as ledger from "..";
import { object, Validation } from "./base";
import { RequiredValidation } from "./base/typelevel";
import { Timestamp } from "./timestamp";

function required(): RequiredValidation<ledger.SetTimeRequest> {
    return {
        currentTime: Timestamp,
        newTime: Timestamp,
    };
}

export const SetTimeRequest: Validation = object<ledger.SetTimeRequest>('SetTimeRequest', required, () => ({}));