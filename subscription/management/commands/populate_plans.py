from django.core.management.base import BaseCommand
from subscription.models import SubscriptionPlan

class Command(BaseCommand):
    help = 'Populate the database with predefined subscription plans'

    def handle(self, *args, **kwargs):
        plans_data = [
            {
                'plan_type': 'bronze',
                'monthly_prices': {"US": 10.0, "IN": 750.0, "GB": 8.0},
                'annual_prices': {"US": 100.0, "IN": 7500.0, "GB": 80.0}
            },
            {
                'plan_type': 'silver',
                'monthly_prices': {"US": 20.0, "IN": 1500.0, "GB": 16.0},
                'annual_prices': {"US": 200.0, "IN": 15000.0, "GB": 160.0}
            },
            {
                'plan_type': 'gold',
                'monthly_prices': {"US": 30.0, "IN": 2500.0, "GB": 24.0},
                'annual_prices': {"US": 300.0, "IN": 25000.0, "GB": 240.0}
            }
        ]

        for plan_data in plans_data:
            plan, created = SubscriptionPlan.objects.get_or_create(
                plan_type=plan_data['plan_type'],
                defaults={
                    'monthly_prices': plan_data['monthly_prices'],
                    'annual_prices': plan_data['annual_prices']
                }
            )

            if created:
                self.stdout.write(self.style.SUCCESS(f'Added {plan.plan_type} plan'))
            else:
                self.stdout.write(self.style.WARNING(f'{plan.plan_type} plan already exists'))

        self.stdout.write(self.style.SUCCESS('Subscription plans populated successfully!'))
