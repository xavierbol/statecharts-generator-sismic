import unittest
from sismic.io import import_from_yaml
from sismic.interpreter import Interpreter
from stopwatch import context


class StopwatchTests(unittest.TestCase):
    def setUp(self):
        with open("stopwatch.yaml") as f:
            sc = import_from_yaml(f)

        self.stopwatch = Interpreter(sc, initial_context=context)
        self.stopwatch.execute_once()

    def test_increase_elapsed_time(self):
        self.stopwatch.queue("start")
        self.stopwatch.execute()
        self.stopwatch.clock.time += 1
        self.stopwatch.execute()
        self.assertEqual(self.stopwatch.context["elapsed_time"], 1)

    def test_reset(self):
        self.stopwatch.queue("start")
        self.stopwatch.execute()
        self.stopwatch.clock.time += 1
        self.stopwatch.execute()
        self.assertEqual(self.stopwatch.context["elapsed_time"], 1)
        self.stopwatch.clock.time += 1
        self.stopwatch.execute()
        self.assertEqual(self.stopwatch.context["elapsed_time"], 2)

        self.stopwatch.queue("stop", "reset")
        self.stopwatch.execute_once()
        self.assertIn("stopped", self.stopwatch.configuration)
        self.assertIn("actual time", self.stopwatch.configuration)
        self.stopwatch.execute_once()
        self.assertIn("stopped", self.stopwatch.configuration)
        self.assertIn("actual time", self.stopwatch.configuration)
        self.assertEqual(self.stopwatch.context["elapsed_time"], 0)


if __name__ == "__main__":
    unittest.main()
