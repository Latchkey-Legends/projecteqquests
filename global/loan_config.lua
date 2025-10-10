-- Loan System Shared Configuration
local config_loans = {}

config_loans.SICKNESS_SPELL_ID = 43000 -- Penalty spell
config_loans.SUPER_MOB_NPC_ID = 501000 -- Super mob NPC ID
config_loans.SUPER_MOB_CHANCE = .25 -- Chance to spawn super mob
config_loans.SUPER_MOB_DEPOP_MINUTES = 1 -- Supermob depop time in minutes (default 3)
config_loans.BASE_LOAN_DURATION_MINUTES = 1 -- Loan duration in minutes (set to 1 for testing, 1440 for 24h, 2880 for 48h)
config_loans.BASE_INTEREST_RATE = 0.05 -- 5% base interest
config_loans.EXTENSION_INTEREST_RATE = 0.025 -- 2.5% per extension
config_loans.MAX_EXTENSIONS = 3
config_loans.LOAN_OPTIONS = {50, 100, 250, 500, 750, 1000, 2000, 5000} -- Possible loan amounts
config_loans.CURRENCY_ID = 40 -- Alt currency ID
config_loans.CURRENCY_ITEM_ID = 500000 -- Alt currency item ID
config_loans.FACTION_ID = 500000 -- Lenders Guild faction


config_loans.BUCKET_KEYS = {
    loan = "loan_%s",
    duration = "loan_duration_%s",
    extensions = "loan_extensions_%s",
    interest = "loan_interest_%s"
}

return config_loans
