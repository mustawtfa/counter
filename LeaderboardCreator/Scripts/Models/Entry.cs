using Dan.Main;
using UnityEngine;

namespace Dan.Models
{
    [System.Serializable]
    public struct Entry
    {
        public string Username;
        public int Score;
        public ulong Date;
        public string Extra;
        public int Rank;
        [SerializeField] internal string UserGuid;
        [field: System.NonSerialized] internal string NewUsername { get; set; }
        
        /// <summary>
        /// Returns whether the entry is the current user's entry.
        /// </summary>
        public bool IsMine() => UserGuid == LeaderboardCreator.UserGuid;
    }
}