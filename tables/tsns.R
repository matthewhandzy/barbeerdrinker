bills <- read_csv("~/Documents/barbeerdrinker/tables/bills.csv")
tsns_times <- read_csv("~/Documents/barbeerdrinker/tables/tsns_times.csv")

# reduce bills to single transaction_id (PK), and include name/bar of tsn
# compute subtotal
tsns <- bills %>%
  group_by(name, bar, transaction_id) %>%
  summarise(subtotal = sum(quantity*price)) %>%
  ungroup()

tsns$date <- tsns_times$date
tsns$time <- tsns_times$time

# generate a random tip between 10-20% of the subtotal
tip_pct <- tbl_df(tbl_df(runif(nrow(tsns), 10, 20))/100)

# add tip column and calculate total using 7% sales tax
tsns <- tsns %>%
  mutate(tip = subtotal * tip_pct$value) %>%
  mutate(total = (subtotal + subtotal*0.07) + tip)

# round numerical columns
tsns$subtotal <- round(tsns$subtotal,2)
tsns$tip <- round(tsns$tip, 2)
tsns$total <- round(tsns$total, 2)

tsns <- tsns %>%
  select(transaction_id,
         drinker_name = name,
         bar_name = bar,
         time,
         date,
         subtotal,
         tip,
         total
  )

write_csv(tsns, "~/tsns.csv")
