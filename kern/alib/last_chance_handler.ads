-- Copyright (C) 2024 Florian Marrero Liestmann
-- SPDX-License-Identifier:  GPL-3.0-only

with System;

procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer);
pragma Export (C, Last_Chance_Handler, "__gnat_last_chance_handler");
