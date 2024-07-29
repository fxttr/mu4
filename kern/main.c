// Copyright (C) 2024 Florian Marrero Liestmann
// SPDX-License-Identifier:  GPL-3.0-only

void bootstrap(void);
void bootstrap_smp(void);

// This is here just for convenience
int main(void)
{
	bootstrap();
}

// Bootstrapping the first CPU core.
void bootstrap(void)
{
}

// After setting up the other CPU cores, they will end up here.
void bootstrap_smp(void)
{
}