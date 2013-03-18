//
//  PlexAutoUpdate.cpp
//  Plex
//
//  Created by Tobias Hieta <tobias@plexapp.com> on 2012-10-24.
//  Copyright 2012 Plex Inc. All rights reserved.
//

#include "PlexAutoUpdate.h"
#include <boost/foreach.hpp>

#include "plex/PlexUtils.h"

#ifdef __APPLE__
#include "Mac/PlexAutoUpdateMac.h"
#endif

#ifdef TARGET_WINDOWS
#include "Win\PlexAutoUpdateInstallerWin.h"
#endif

CPlexAutoUpdate::CPlexAutoUpdate(const std::string &updateUrl, int searchFrequency) :
  CThread("AutoUpdateThread"),
  m_updateUrl(updateUrl),
  m_searchFrequency(searchFrequency),
  m_currentVersion(PLEX_VERSION)
{
  m_functions = new CAutoUpdateFunctionsXBMC(this);
#ifdef TARGET_DARWIN_OSX
  m_installer = new CPlexAutoUpdateInstallerMac(m_functions);
#elif defined(TARGET_WINDOWS)
  m_installer = new CPlexAutoUpdateInstallerWin(m_functions);
#endif

  Create();
}

void CPlexAutoUpdate::Process()
{
  m_functions->LogDebug("Thread is running...");

  Sleep(10000);

  while (!m_bStop)
  {
    _CheckForNewVersion();

    m_functions->LogDebug("Thread is going back to sleep");
    m_RunEvent.WaitMSec(m_searchFrequency * 1000);
  }
}

bool CPlexAutoUpdate::DownloadNewVersion()
{
  std::string localPath;
  std::string destination;
  if (m_functions->DownloadFile(m_newVersion.m_enclosureUrl, localPath))
  {
    // Successful download
    if(m_functions->ShouldWeInstall(localPath))
    {
      m_installer->InstallUpdate(localPath, destination);
    }
  }
  
  return true;
}

std::string CPlexAutoUpdate::GetOsName() const
{
  return PlexUtils::GetMachinePlatform();
}

bool CPlexAutoUpdate::_CheckForNewVersion()
{
  std::string data;
  m_functions->LogInfo("Checking for new version");
  if (m_functions->FetchUrlData(m_updateUrl, data))
  {
    CAutoUpdateInfoList list;
    if (m_functions->ParseXMLData(data, list))
    {
      BOOST_FOREACH(CAutoUpdateInfo info, list)
      {
        if (info.m_enclosureOs != GetOsName())
          continue;

        m_functions->LogInfo("Found version " + info.m_enclosureVersion.GetVersionString());

        if(m_currentVersion < info.m_enclosureVersion)
        {
          m_functions->LogInfo("Found new version " + info.m_enclosureVersion.GetVersionString());
          m_newVersion = info;
          m_functions->NotifyNewVersion();

          return true;
        }
      }
    }
  }
  m_functions->LogInfo("No new version found!");
  return false;
}
