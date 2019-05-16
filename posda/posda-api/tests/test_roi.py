import asynctest

from papi.util import roi
from numpy import matrix, array_equal


class TestRoi(asynctest.TestCase):
    async def test_get_transformed_contour(self):
        """Test the only method from the roi and roimath that is ever
        directly called. All other methods are implementation details
        """
        mock = asynctest.CoroutineMock()
        mock.return_value = '1\\2\\3\\4\\5\\6'
        roi.get_contour_data_from_file = mock

        contour = await roi.get_transformed_contour(
            8,              # length
            2,              # num_points
            22,             # offset
            'filename',     # filename
            '1\\2.5\\3\\4\\5.8\\6',         # iop
            '1.234\\1.834\\0',         # ipp
            '2\\1')              # pixel_spacing

        mock.assert_called_with('filename', 22, 8)
        self.assertTrue(array_equal(contour, matrix([[4, 18], [14, 65]])))
