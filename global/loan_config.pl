# Loan System Shared Configuration (Perl)

sub get_loan_config {
    return {
        SICKNESS_SPELL_ID => 43000, # Penalty spell
        SUPER_MOB_NPC_ID => 501000, # Super mob NPC ID
        SUPER_MOB_CHANCE => 0.25,   # Chance to spawn super mob
        SUPER_MOB_DEPOP_MINUTES => 1, # Supermob depop time in minutes
        BASE_LOAN_DURATION_MINUTES => 1, # Loan duration in minutes (set to 1 for testing, 1440 for 24h, 2880 for 48h)
        BASE_INTEREST_RATE => 0.05, # 5% base interest
        EXTENSION_INTEREST_RATE => 0.025, # 2.5% per extension
        MAX_EXTENSIONS => 3,
        LOAN_OPTIONS => [50, 100, 250, 500, 750, 1000, 2000, 5000], # Possible loan amounts
        CURRENCY_ID => 40, # Alt currency ID
        CURRENCY_ITEM_ID => 500000, # Alt currency item ID
        FACTION_ID => 500000, # Lenders Guild faction
        BUCKET_KEYS => {
            loan => "loan_%s",
            duration => "loan_duration_%s",
            extensions => "loan_extensions_%s",
            interest => "loan_interest_%s"
        }
    };
}

1;
