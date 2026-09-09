import subprocess
import unittest
from unittest.mock import patch, MagicMock
from simulate_privacy.studies import Study, Result

class TestReplicateMethod(unittest.TestCase):
    def setUp(self):
        self.study_id = 'autor-2013'
        self.expected_results = [
            Result('d_tradeusch_pw-empl', est=-0.596, se=0.099)
        ]
        self.study = Study.from_id(self.study_id)

    @patch('subprocess.run')
    def test_replicate(self, mock_subprocess):
        mock_subprocess.return_value = MagicMock()

        self.study.replicate()

        mock_subprocess.assert_called_once_with(
            "make results",
            cwd=self.study.path(),
            shell=True,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        results = self.study.extract_results()

        self.assertEqual(results, self.expected_results, "The replicated results do not match the expected results")

if __name__ == "__main__":
    unittest.main()
