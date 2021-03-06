# encoding: utf-8

# ***************************************************************************
#
# Copyright (c) 2002 - 2012 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#
# ***************************************************************************
# File:	FileUtils.ycp
# Package:	YaST modules
# Summary:	Testsuite for FileUtils Module
# Authors:	Lukas Ocilka <locilka@suse.cz>
# Copyright:	Copyright 2004, Novell, Inc.  All rights reserved.
#
# $Id$
#
# Testsuite for FileUtils YCP module.
module Yast
  class FileUtilsClient < Client
    def main
      Yast.include self, "testsuite.rb"
      # testedfiles: FileUtils

      @I_READ = {}
      @I_WRITE = {}
      @I_EXEC = {}

      TESTSUITE_INIT([@I_READ, @I_WRITE, @I_EXEC], nil)

      Yast.import "FileUtils"
      Yast.import "Mode"

      Mode.SetMode("test")

      # Each test has its own READ map. Some use lstat some use stat.
      # IsAnything should return true, false, nil.

      # Existence of file
      @READ_EXISTS_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => true,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 804,
            "uid"     => 0
          }
        }
      }
      # File doesn't exist
      @READ_EXISTS_2 = { "target" => { "stat" => {} } }
      # File doesn't exist
      @READ_EXISTS_3 = { "target" => { "lstat" => {} } }

      # Directory
      @READ_DIRECTORY_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => true,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }
      @READ_DIRECTORY_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => true,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 804,
            "uid"     => 0
          }
        }
      }

      # Regular file
      @READ_FILE_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => true,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 804,
            "uid"     => 0
          }
        }
      }
      @READ_FILE_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }

      # Block
      @READ_BLOCK_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101195257,
            "ctime"   => 1097483383,
            "gid"     => 6,
            "inode"   => 27982,
            "isblock" => true,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1096706283,
            "nlink"   => 1,
            "size"    => 0,
            "uid"     => 0
          }
        }
      }
      @READ_BLOCK_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => true,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }

      # Fifo
      @READ_FIFO_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101195257,
            "ctime"   => 1097483383,
            "gid"     => 6,
            "inode"   => 27982,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1096706283,
            "nlink"   => 1,
            "size"    => 0,
            "uid"     => 0
          }
        }
      }
      @READ_FIFO_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => true,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }

      # Link
      @READ_LINK_1 = {
        "target" => {
          # Link uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => true,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_LINK_2 = {
        "target" => {
          # Link uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => true,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }

      # Socket
      @READ_SOCKET_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => true,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }
      @READ_SOCKET_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }

      # Character device
      @READ_CHARACTERDEVICE_1 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => true,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => true,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }
      @READ_CHARACTERDEVICE_2 = {
        "target" => {
          "stat" => {
            "atime"   => 1101890288,
            "ctime"   => 1101890286,
            "gid"     => 0,
            "inode"   => 29236,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1101890286,
            "nlink"   => 1,
            "size"    => 55888,
            "uid"     => 0
          }
        }
      }

      # Checking real type of file, link? returns link! instead of linked object's file.
      # Using "lstat"
      @READ_REALTYPE_1 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => true,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_2 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => true,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_3 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => true,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_4 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_5 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => true,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_6 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => true,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_7 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => true,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_REALTYPE_UNKNOWN = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "lstat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }

      # Checking relative type of file, link? returns linked object! instead of link!.
      # using "stat"
      @READ_UNREALTYPE_1 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => true,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_2 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => true,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_3 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => true,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_4 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => true,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_5 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => true,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_6 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => true,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_7 = {
        "target" => {
          # RealType uses "lstat" instead of "stat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => true,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }
      @READ_UNREALTYPE_UNKNOWN = {
        "target" => {
          # UnrealType uses "stat" instead of "lstat"
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 0
          }
        }
      }

      @READ_USER = {
        "target" => {
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 0,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 1003
          }
        }
      }

      @READ_GROUP = {
        "target" => {
          "stat" => {
            "atime"   => 1101892352,
            "ctime"   => 1100268833,
            "gid"     => 500,
            "inode"   => 19561,
            "isblock" => false,
            "ischr"   => false,
            "isdir"   => false,
            "isfifo"  => false,
            "islink"  => false,
            "isreg"   => false,
            "issock"  => false,
            "mtime"   => 1100268833,
            "nlink"   => 1,
            "size"    => 5,
            "uid"     => 1003
          }
        }
      }

      @READ_SIZE = { "target" => { "size" => 58899 } }

      @WRITE = {}
      @EXEC = {}


      @tested_file = "/file/name/anywhere.is"

      DUMP("=Exists===============>")
      TEST(lambda { FileUtils.Exists(@tested_file) }, [
        @READ_EXISTS_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.Exists(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsDirectory==========>")
      TEST(lambda { FileUtils.IsDirectory(@tested_file) }, [
        @READ_DIRECTORY_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsDirectory(@tested_file) }, [
        @READ_DIRECTORY_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsDirectory(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsFile===============>")
      TEST(lambda { FileUtils.IsFile(@tested_file) }, [
        @READ_FILE_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsFile(@tested_file) }, [
        @READ_FILE_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsFile(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsBlock==============>")
      TEST(lambda { FileUtils.IsBlock(@tested_file) }, [
        @READ_BLOCK_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsBlock(@tested_file) }, [
        @READ_BLOCK_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsBlock(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsFifo===============>")
      TEST(lambda { FileUtils.IsFifo(@tested_file) }, [
        @READ_FIFO_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsFifo(@tested_file) }, [
        @READ_FIFO_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsFifo(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsLink===============>")
      TEST(lambda { FileUtils.IsLink(@tested_file) }, [
        @READ_LINK_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsLink(@tested_file) }, [
        @READ_LINK_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsLink(@tested_file) }, [
        @READ_EXISTS_3,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsSocket=============>")
      TEST(lambda { FileUtils.IsSocket(@tested_file) }, [
        @READ_SOCKET_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsSocket(@tested_file) }, [
        @READ_SOCKET_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsSocket(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=IsCharacterDevice====>")
      TEST(lambda { FileUtils.IsCharacterDevice(@tested_file) }, [
        @READ_CHARACTERDEVICE_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsCharacterDevice(@tested_file) }, [
        @READ_CHARACTERDEVICE_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.IsCharacterDevice(@tested_file) }, [
        @READ_EXISTS_2,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=GetFileRealType======>")
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_3,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_4,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_5,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_6,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_7,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileRealType(@tested_file) }, [
        @READ_REALTYPE_UNKNOWN,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=GetFileType======>")
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_1,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_2,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_3,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_4,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_5,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_6,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_7,
        @WRITE,
        @EXEC
      ], 0)
      TEST(lambda { FileUtils.GetFileType(@tested_file) }, [
        @READ_UNREALTYPE_UNKNOWN,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=GetSize==========>")
      TEST(lambda { FileUtils.GetSize(@tested_file) }, [
        @READ_SIZE,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=GetOwnerUserID===>")
      TEST(lambda { FileUtils.GetOwnerUserID(@tested_file) }, [
        @READ_USER,
        @WRITE,
        @EXEC
      ], 0)
      DUMP("=GetOwnerGroupID==>")
      TEST(lambda { FileUtils.GetOwnerGroupID(@tested_file) }, [
        @READ_GROUP,
        @WRITE,
        @EXEC
      ], 0)

      nil
    end
  end
end

Yast::FileUtilsClient.new.main
