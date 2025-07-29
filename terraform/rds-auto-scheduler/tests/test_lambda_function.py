from datetime import date, datetime, timedelta

from src.lambda_function import get_custom_holidays, get_japanese_holidays


def test_lambda_function(year=None):
    """Test lambda function holiday detection functionality"""
    if year is None:
        year = datetime.now().year
    current_year = year

    print("Testing lambda function holiday detection...")

    # Get custom holidays
    custom_holidays = get_custom_holidays()
    print(f"🗓️ Custom holidays: {len(custom_holidays)}")

    # Get official holidays
    official_holidays = get_japanese_holidays(current_year)
    print(f"🗓️ Official holidays: {len(official_holidays)}")

    # Combined holidays
    all_holidays = official_holidays.union(custom_holidays)
    print(f"🗓️ Total holidays: {len(all_holidays)}")

    # Test all dates in specified year
    start_date = date(current_year, 1, 1)
    end_date = date(current_year, 12, 31)
    test_dates = []

    current_date = start_date
    while current_date <= end_date:
        test_dates.append(current_date.strftime("%Y-%m-%d"))
        current_date += timedelta(days=1)

    print("\nTesting specific dates:")
    weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    for test_date in test_dates:
        date_obj = datetime.strptime(test_date, "%Y-%m-%d").date()
        is_weekend = date_obj.weekday() >= 5  # Saturday=5, Sunday=6
        day_of_week = weekdays[date_obj.weekday()]

        if test_date in official_holidays:
            print(f" {test_date} ({day_of_week}): Official holiday ⏸️")
        elif test_date in custom_holidays:
            print(f" {test_date} ({day_of_week}): Custom holiday ⏸️")
        elif is_weekend:
            print(f" {test_date} ({day_of_week}): Weekend ⏸️")
        else:
            print(f" {test_date} ({day_of_week}): Working day ✅️")


if __name__ == "__main__":
    import sys

    year = None
    if len(sys.argv) > 1:
        try:
            year = int(sys.argv[1])
        except ValueError:
            print("Usage: python3 test_custom_holidays.py [YYYY]")
            sys.exit(1)

    test_lambda_function(year)
