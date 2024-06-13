using System;
using Dan.Models;
using Dan.Demo;
using Dan.Main;

[ApiController]
[Route("[controller]")]
public class LeaderboardController : ControllerBase
{
    private readonly LeaderboardCreator _leaderboardCreator;

    public LeaderboardController(LeaderboardCreator leaderboardCreator)
    {
        _leaderboardCreator = leaderboardCreator;
    }

    [HttpGet("getLeaderboardFormatted")]
    public IActionResult GetLeaderboardFormatted()
    {
    string leaderboardPublicKey = "4dda90b6e733cdccd3d1df587094f5a7f2d995c5b2f4163cbac64a07a1e854f9";
    string formattedData = "";

    _leaderboardCreator.GetLeaderboard(leaderboardPublicKey, entries =>
    {
        if (entries.Length > 0)
        {
            formattedData = string.Join("\n", entries.Select(entry => $"Ad: {entry.Username}, Puan: {entry.Score}"));
        }
        else
            {
            formattedData = "Girdi bulunamadı";
            }
        }, error =>
        {
            formattedData = "SIKINTI VAR:" + error;
        });

        return Ok(formattedData);
    }
}