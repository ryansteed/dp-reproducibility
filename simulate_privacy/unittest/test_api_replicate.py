import unittest
from click.testing import CliRunner
from simulate_privacy.api import cli
from simulate_privacy.studies import Study, Result


class TestApiReplicate(unittest.TestCase):
    def setUp(self):
        self.study_id = 'autor-2013'
        self.expected_results = [
            Result('d_tradeusch_pw-empl', est=-0.596, se=0.099)
        ]
        self.study = Study.from_id(self.study_id)


    def test_replicate(self):
        result = CliRunner().invoke(cli, ['replicate', self.study_id])

        # Check the command executed successfully
        self.assertEqual(result.exit_code, 0, "CLI command did not exit cleanly")
    

    def test_epsilon(self):
        result = CliRunner().invoke(cli, ['replicate', '--epsilon', 0.1, self.study_id])

        # Check the command executed successfully
        self.assertEqual(result.exit_code, 0, "CLI command did not exit cleanly")


if __name__ == "__main__":
    unittest.main()
