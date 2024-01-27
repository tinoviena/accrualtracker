list_of_dicts = [{'value': 1}, {'value': 2}, {'value': 3}]
sum_of_values = sum(d['value'] for d in list_of_dicts)

print(sum_of_values)
