
# ================================================================
# EQEmu Quest Script
# File: 500002.pl
# Purpose: Zork the Broker - Modular Alternate Currency Loan System
# Author: [Your Name or Team]
# Date: 2025-09-29
# Server: ProjectEQQuests
# ================================================================
# This file is part of the ProjectEQQuests repository.
# For documentation and API info, see @docs/Spire-API-info.md
# ================================================================

use lib '.';
do 'loan_config.pl';

# CONFIGURATION (now loaded from plugin::loan_config)
my $config_loans = plugin::loan_config();
my $currency_id = $config_loans->{CURRENCY_ID};
my $currency_item_id = $config_loans->{CURRENCY_ITEM_ID};
my $BASE_LOAN_DURATION_MINUTES = $config_loans->{BASE_LOAN_DURATION_MINUTES};
my $BASE_INTEREST_RATE = $config_loans->{BASE_INTEREST_RATE};
my $EXTENSION_INTEREST_RATE = $config_loans->{EXTENSION_INTEREST_RATE};
my $MAX_EXTENSIONS = $config_loans->{MAX_EXTENSIONS};
my $LOAN_OPTIONS = $config_loans->{LOAN_OPTIONS};
my $SICKNESS_SPELL_ID = $config_loans->{SICKNESS_SPELL_ID};
my $FACTION_ID = $config_loans->{FACTION_ID};

sub get_loan_bucket_keys {
    my ($client_id) = @_;
    return {
        loan      => sprintf($config_loans->{BUCKET_KEYS}->{loan}, $client_id),
        duration  => sprintf($config_loans->{BUCKET_KEYS}->{duration}, $client_id),
        extensions=> sprintf($config_loans->{BUCKET_KEYS}->{extensions}, $client_id),
        interest  => sprintf($config_loans->{BUCKET_KEYS}->{interest}, $client_id)
    };
}

sub get_loan_state {
    my ($client, $client_id) = @_;
    return unless $client;
    my $keys = get_loan_bucket_keys($client_id);
    return {
        amount     => $client->GetBucket($keys->{loan}) || 0,
        duration   => $client->GetBucket($keys->{duration}) || 0,
        extensions => $client->GetBucket($keys->{extensions}) || 0,
        interest   => $client->GetBucket($keys->{interest}) || 0
    };
}

sub set_loan_state {
    my ($client, $client_id, $amount, $duration, $extensions, $interest) = @_;
    return unless $client;
    my $keys = get_loan_bucket_keys($client_id);
    $client->SetBucket($keys->{loan}, $amount);
    $client->SetBucket($keys->{duration}, $duration);
    $client->SetBucket($keys->{extensions}, $extensions);
    $client->SetBucket($keys->{interest}, $interest);
}

sub clear_loan_state {
    my ($client, $client_id) = @_;
    return unless $client;
    my $keys = get_loan_bucket_keys($client_id);
    $client->DeleteBucket($keys->{loan});
    $client->DeleteBucket($keys->{duration});
    $client->DeleteBucket($keys->{extensions});
    $client->DeleteBucket($keys->{interest});
}

sub show_loan_info {
    my ($client, $client_id) = @_;
    my $state = get_loan_state($client, $client_id);
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    if ($state->{amount} > 0) {
        my $total_due = int($state->{amount} * (1 + $state->{interest}));
        my $interest_str = sprintf('%.1f%%', $state->{interest} * 100);
        $interest_str =~ s/\.0%$/%/;
        my $now = time();
        my $time_left = $state->{duration} - $now;
        my $hours = int($time_left / 3600);
        my $minutes = int(($time_left % 3600) / 60);
        my $seconds = $time_left % 60;
        my $time_str = sprintf("%02dh %02dm %02ds", $hours, $minutes, $seconds);
        $client->Message(0, "Current Loan Information:");
        $client->Message(0, "Amount borrowed: $state->{amount} $currency_name");
        $client->Message(0, "Total owed (with interest): $total_due $currency_name");
        $client->Message(0, "Interest rate: $interest_str");
        $client->Message(0, "Extensions used: $state->{extensions}/$MAX_EXTENSIONS");
        $client->Message(0, "Time remaining: $time_str");
    } else {
        $client->Message(0, "You do not have an active loan.");
    }
}

sub show_loan_menu {
    my ($client, $client_id) = @_;
    my $state = get_loan_state($client, $client_id);
    my $FACTION_ID = 500000;
    my $faction_level = $client->GetCharacterFactionLevel($FACTION_ID);
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    if ($state->{amount} > 0) {
        my $payback_link = quest::saylink('payback_loan', 0, 'Payback Loan');
        my $extend_link = quest::saylink('extend_loan', 0, 'Extend Loan');
        my $regain_link = quest::saylink('regain_favor', 0, 'Regain Favor');
        my $total_due = int($state->{amount} * (1 + $state->{interest}));
        my $now = time();
        my $overdue_msg = '';
        my $loan_duration = $BASE_LOAN_DURATION_MINUTES * 60;
        if ($now > $state->{duration}) {
            my $overdue_seconds = $now - $state->{duration};
            my $overdue_periods = int($overdue_seconds / $loan_duration);
            my $overdue_str = sprintf("%02dh %02dm %02ds", int($overdue_seconds / 3600), int(($overdue_seconds % 3600) / 60), $overdue_seconds % 60);
            $overdue_msg = "Your loan is OVERDUE by $overdue_str ($overdue_periods full periods past due).";
        }

        $client->Message(0, "You currently have an outstanding loan of $state->{amount} $currency_name.");
        $client->Message(0, "Total owed (with interest): $total_due $currency_name");
        $client->Message(0, "Interest rate: " . sprintf("%.2f%%", $state->{interest} * 100) . ". Extensions: $state->{extensions}/$MAX_EXTENSIONS");
        if ($overdue_msg ne '') {
            $client->Message(13, $overdue_msg);
        } else {
            $client->Message(0, "Time remaining: " . plugin::format_time($state->{duration} - $now) . " (HH:MM:SS)");
        }
        if ($faction_level < -500) {
            $client->Message(13, "Your reputation with the Lenders Guild is ruined! Only repayment or regaining favor will restore your standing.");
            $client->Message(0, "Click here to pay back your loan: $payback_link");
            $client->Message(0, "Click here to regain favor: $regain_link");
        } else {
            $client->Message(0, "Click here to pay back your loan: $payback_link");
            if ($state->{extensions} < $MAX_EXTENSIONS) {
                $client->Message(0, "Need more time? Click here to extend your loan: $extend_link");
            }
        }
    } else {
    my $hours = int($BASE_LOAN_DURATION_MINUTES / 60);
    my $base_interest_val = $BASE_INTEREST_RATE * 100;
    my $base_interest_str = sprintf('%.1f%%%', $base_interest_val);

    my $extension_interest_val = $EXTENSION_INTEREST_RATE * 100;
    my $extension_interest_str = sprintf('%.1f%%%', $extension_interest_val);

    my $terms_message = "Zork chuckles. Very well my friend. Here are my terms. You may borrow $currency_name for $hours hours at a base interest rate of $base_interest_str. If you need more time, you may extend your loan up to $MAX_EXTENSIONS times, with interest increasing by $extension_interest_str for each extension. You must repay the full amount plus interest before the deadline, or pay partially and the remaining balance will continue to accrue interest. Speak to me again about a [loan] and I will give you details about our current loan. Failure WILL have dire [consequences]. And I won't loan to you again for a good while!";
    $client->Message(0, $terms_message);
        $client->Message(0, "So, how much do you want?");
        foreach my $amount (@$LOAN_OPTIONS) {
            my $link = quest::saylink('loan_' . $amount, 0, 'Borrow ' . $amount . ' ' . $currency_name);
            $client->Message(0, $link);
        }
    }
}

sub process_loan {
    my ($client, $client_id, $amount) = @_;
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    my $state = get_loan_state($client, $client_id);
    if ($state->{amount} > 0) {
        $client->Message(13, "You already have an outstanding loan.");
        return;
    }
    my $duration = time() + $BASE_LOAN_DURATION_MINUTES * 60;
    my $interest = $BASE_INTEREST_RATE;
    set_loan_state($client, $client_id, $amount, $duration, 0, $interest);
    $client->SummonItem($currency_item_id, $amount);
    my $hours = sprintf('%.2f', $BASE_LOAN_DURATION_MINUTES / 60);
    my $interest_rate = sprintf('%.2f%%%', $interest * 100);
    $client->Message(0, "You have borrowed $amount $currency_name. You have $hours hours to repay at $interest_rate interest.");
}

sub process_payback {
    # Payback logic with input validation and standardized faction handling
    my ($client, $client_id) = @_;
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    my $state = get_loan_state($client, $client_id);
    unless ($client && $client_id) {
        $client->Message(13, "Internal error: missing client or client_id.");
        return;
    }
    if ($state->{amount} == 0) {
        $client->Message(13, "You do not have an outstanding loan to pay back.");
        return;
    }
    my $inv_count = $client->CountItem($currency_item_id);
    my $total_due = int($state->{amount} * (1 + $state->{interest}));
    if ($inv_count == 0) {
        $client->Message(13, "You do not have any $currency_name in your inventory to pay back your loan. You owe $total_due $currency_name (including interest).");
        return;
    }
    if ($inv_count < $total_due) {
        $client->RemoveItem($currency_item_id, $inv_count);
        my $paid_ratio = $inv_count / $total_due;
        my $new_amount = int($state->{amount} * (1 - $paid_ratio));
        if ($new_amount < 1) {
            clear_loan_state($client, $client_id);
            $client->Message(0, "You have paid off your loan in full. Thank you!");
            $client->BuffFadeBySpellID($SICKNESS_SPELL_ID);
            plugin::SetFactionStatic($client, $FACTION_ID, -500); # Set to neutral after payback
        } else {
            set_loan_state($client, $client_id, $new_amount, $state->{duration}, $state->{extensions}, $state->{interest});
            my $new_due = int($new_amount * (1 + $state->{interest}));
            $client->Message(0, "You paid $inv_count $currency_name. Remaining loan: $new_amount $currency_name. Total owed (with interest): $new_due $currency_name");
        }
    } else {
        $client->RemoveItem($currency_item_id, $total_due);
        clear_loan_state($client, $client_id);
        $client->Message(0, "Your loan of $state->{amount} $currency_name has been paid back. Total paid: $total_due (including interest). Thank you!");
        $client->BuffFadeBySpellID($SICKNESS_SPELL_ID);
        plugin::SetFactionStatic($client, $FACTION_ID, -500); # Set to neutral after payback
    }
}

sub process_extend {
    my ($client, $client_id) = @_;
    my $state = get_loan_state($client, $client_id);
    if ($state->{amount} == 0) {
        $client->Message(13, "You do not have an outstanding loan to extend.");
        return;
    }
    if ($state->{extensions} >= $MAX_EXTENSIONS) {
        $client->Message(13, "You have reached the maximum number of extensions.");
        return;
    }
    my $new_extensions = $state->{extensions} + 1;
    my $new_interest = $BASE_INTEREST_RATE * ($new_extensions + 1);
    my $new_duration = time() + $BASE_LOAN_DURATION_MINUTES * 60;
    set_loan_state($client, $client_id, $state->{amount}, $new_duration, $new_extensions, $new_interest);
    plugin::SetFactionStatic($client, $FACTION_ID, 0); # Set to neutral after extension
    $client->Message(0, "Your loan has been extended. New interest rate: " . sprintf("%.2f%%", $new_interest * 100) . ". You now have 24 more hours to pay back your loan. Your standing with the Lenders Guild is now neutral.");
}

sub show_balance {
    my ($client) = @_;
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    my $tab_count = $client->GetAlternateCurrencyValue($currency_id);
    $client->Message(0, "You currently have $tab_count $currency_name in your alt currency tab.");
}

sub redeem_inventory {
    my ($client) = @_;
    my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
    my $tab_count = $client->GetAlternateCurrencyValue($currency_id);
    my $inventory_count = $client->CountItem($currency_item_id);
    if ($inventory_count > 0) {
        $client->RemoveItem($currency_item_id, $inventory_count);
    }
    my $total = $tab_count + $inventory_count;
    $client->SetAlternateCurrencyValue($currency_id, $total);
    if ($inventory_count > 0) {
        $client->Message(0, "You redeemed $inventory_count $currency_name from your inventory. Your total is now $total.");
    } else {
        $client->Message(0, "You have no $currency_name in your inventory to redeem. Your total remains $tab_count.");
    }
}

sub EVENT_SAY {
    # $client is provided by EQEmu automatically
    my $client_id = $client ? $client->CharacterID() : undef;
    my $FACTION_ID = 500000;
    my $faction_level = $client ? $client->GetCharacterFactionLevel($FACTION_ID) : 0;
    $client->Message(15, "DEBUG: Your current faction with the Lenders Guild is: $faction_level");
    if ($text =~ /Hail/i) {
        my $state = get_loan_state($client, $client_id);
        my $payback_link = quest::saylink('payback_loan', 0, 'Payback Loan');
        my $regain_link = quest::saylink('regain_favor', 0, 'Regain Favor');
        if ($faction_level <= -500) {
			my $message_text = "You expect me to do business with you? No way. You can ";
			if($state->{amount} > 0) {
				show_loan_info($client, $client_id);
				$message_text .= " $payback_link";
			} else {
				$message_text .= " attempt to $regain_link with the Lenders Guild.";
			}
            $client->Message(13, $message_text);
            return;
        }
        my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
        my $redeem_link = quest::saylink('redeem', 0, 'Redeem');
        my $balance_link = quest::saylink('show balance', 0, 'Balance');
        my $loan_link = quest::saylink('loan', 0, 'Loan');
        $client->Message(0, "Zork says, Zork! I am the Master of Resilience. The broker of this worlds alternate currency system. Would you like some " . quest::saylink('information', 0, 'information') . " about the currency system? Or you can say $redeem_link to change all currency in your inventory to items. Or I can show you your $balance_link.");
        if ($state->{amount} > 0) {
            show_loan_menu($client, $client_id);
        } else {
            $client->Message(0, "Psst. I can $loan_link you some $currency_name.");
        }
    } elsif ($text =~ /redeem/i) {
        redeem_inventory($client);
    } elsif ($text =~ /show balance/i) {
        show_balance($client);
    } elsif ($text =~ /information/i) {
        my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
        $client->Message(0, "You earn $currency_name by defeating monsters throughout Norrath. The amount you receive is based on the difficulty of the monsters. You can accumulate $currency_name in your inventory as items, which can be redeemed with me to add them to your alternate currency tab. Happy hunting!");
    } elsif ($text =~ /payback_loan/i) {
        process_payback($client, $client_id);
    } elsif ($text =~ /extend_loan/i) {
        process_extend($client, $client_id);
    } elsif ($text =~ /regain_favor/i) {
        $client->Message(0, "To regain favor with the Lenders Guild, you must [pay] me 300 " . quest::getitemname($config_loans->{CURRENCY_ITEM_ID}) . ".");
    } elsif ($text =~ /pay/i) {
        my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
        my $tab_count = $client->GetAlternateCurrencyValue($config_loans->{CURRENCY_ID});
        if ($tab_count >= 300) {
            $client->SetAlternateCurrencyValue($config_loans->{CURRENCY_ID}, $tab_count - 300);
            $client->Message(0, "You have paid 300 $currency_name to regain favor with the Lenders Guild.");
            $client->Message(15, "Faction id is: $config_loans->{FACTION_ID}");
			# my $delta = 0 - $client->GetCharacterFactionLevel($config_loans->{FACTION_ID});
			# quest::faction($config_loans->{FACTION_ID}, $delta);
			plugin::SetFactionStatic($client, $config_loans->{FACTION_ID}, 0);
        } else {
            $client->Message(13, "You do not have enough $currency_name to pay.");
        }
    } else {
        foreach my $amount (@$LOAN_OPTIONS) {
            if ($text =~ /loan_$amount/i) {
                process_loan($client, $client_id, $amount);
                return;
            }
        }
        if ($text =~ /loan/i) {
            show_loan_menu($client, $client_id);
        }
    }
}

# sub show_loan_menu {
#     my ($client, $client_id) = @_;
#     my $state = get_loan_state($client, $client_id);
#     my $FACTION_ID = 500000;
#     my $faction_level = $client->GetCharacterFactionLevel($FACTION_ID);
#     my $currency_name = quest::getitemname($config_loans->{CURRENCY_ITEM_ID});
#     if ($state->{amount} > 0) {
#         my $payback_link = quest::saylink('payback_loan', 0, 'Payback Loan');
#         my $extend_link = quest::saylink('extend_loan', 0, 'Extend Loan');
#         my $regain_link = quest::saylink('regain_favor', 0, 'Regain Favor');
#         my $total_due = int($state->{amount} * (1 + $state->{interest}));
#         my $now = time();
#         my $overdue_msg = '';
#         my $loan_duration = $BASE_LOAN_DURATION_MINUTES * 60;
#         if ($now > $state->{duration}) {
#             my $overdue_seconds = $now - $state->{duration};
#             my $overdue_periods = int($overdue_seconds / $loan_duration);
#             my $overdue_str = sprintf("%02dh %02dm %02ds", int($overdue_seconds / 3600), int(($overdue_seconds % 3600) / 60), $overdue_seconds % 60);
#             $overdue_msg = "Your loan is OVERDUE by $overdue_str ($overdue_periods full periods past due).";
#         }
#         $client->Message(0, "You currently have an outstanding loan of $state->{amount} $currency_name.");
#         $client->Message(0, "Total owed (with interest): $total_due $currency_name");
#         $client->Message(0, "Interest rate: " . sprintf("%.2f%%", $state->{interest} * 100) . ". Extensions: $state->{extensions}/$MAX_EXTENSIONS");
#         if ($overdue_msg ne '') {
#             $client->Message(13, $overdue_msg);
#         } else {
#             $client->Message(0, "Time remaining: " . plugin::format_time($state->{duration} - $now) . " (HH:MM:SS)");
#         }
#         if ($faction_level < -500) {
#             $client->Message(13, "Your reputation with the Lenders Guild is ruined! Only repayment or regaining favor will restore your standing.");
#             $client->Message(0, "Click here to pay back your loan: $payback_link");
#             $client->Message(0, "Click here to regain favor: $regain_link");
#         } else {
#             $client->Message(0, "Click here to pay back your loan: $payback_link");
#             if ($state->{extensions} < $MAX_EXTENSIONS) {
#                 $client->Message(0, "Need more time? Click here to extend your loan: $extend_link");
#             }
#         }
#     } else {
#     my $hours = ($BASE_LOAN_DURATION_MINUTES % 60 == 0) ? int($BASE_LOAN_DURATION_MINUTES / 60) : sprintf('%.2f', $BASE_LOAN_DURATION_MINUTES / 60);
#     my $base_interest_val = $BASE_INTEREST_RATE * 100;
#     my $base_interest_str = ($base_interest_val == int($base_interest_val)) ? int($base_interest_val) . '%' : sprintf('%.2f%%', $base_interest_val);
#     my $extension_interest_val = $EXTENSION_INTEREST_RATE * 100;
#     my $extension_interest_str = ($extension_interest_val == int($extension_interest_val)) ? int($extension_interest_val) . '%' : sprintf('%.2f%%', $extension_interest_val);
#     $client->Message(0, "Zork chuckles. Very well my friend. Here are my terms. You may borrow $currency_name for $hours hours at a base interest rate of $base_interest_str. If you need more time, you may extend your loan up to $MAX_EXTENSIONS times, with interest increasing by $extension_interest_str for each extension. You must repay the full amount plus interest before the deadline, or pay partially and the remaining balance will continue to accrue interest. Speak to me again about a [loan] and I will give you details about our current loan. Failure WILL have dire [consequences]. And I won't loan to you again for a good while!");
#         $client->Message(0, "So, how much do you want?");
#         foreach my $amount (@$LOAN_OPTIONS) {
#             my $link = quest::saylink('loan_' . $amount, 0, 'Borrow ' . $amount . ' ' . $currency_name);
#             $client->Message(0, $link);
#         }
#     }
# }
