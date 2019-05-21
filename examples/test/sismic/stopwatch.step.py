from behave import *
import stopwatch


@given("update context")
def before_all(context):
    context.interpreter.context.update(stopwatch.context)
