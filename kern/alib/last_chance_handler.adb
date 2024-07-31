-- Copyright (C) 2024 Florian Marrero Liestmann
-- SPDX-License-Identifier:  GPL-3.0-only

procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer)
is
    pragma Unreferenced (Source_Location, Line);
begin
    --  TODO: Add in board-specific code to dump exception information to serial/screen.
    loop
        null;
    end loop;
end Last_Chance_Handler;
